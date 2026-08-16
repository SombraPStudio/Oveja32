extends Control

const DIALOGUE_PATH = "res://Dialogues//Test.json"
export(Texture) var default_player_texture = preload("res://icon.png")
export(Texture) var default_object_texture = preload("res://icon.png")

onready var player_rect = $Player
onready var object_rect = $Object
onready var dialogue_label = $Dialogue
onready var choices_container = $ChoisesContainer
onready var tween = $Tween
onready var AudioS = $AudioStreamPlayer

const SCALE_ACTIVE = Vector2(1.0, 1.0)
const SCALE_INACTIVE = Vector2(0.95, 0.95)
const COLOR_ACTIVE = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_INACTIVE = Color(0.4, 0.4, 0.4, 1.0)
const TRANSITION_TIME = 0.25

export(float) var VELOCIDAD_ESCRITURA = 0.08

export (AudioStream) var Player_sonido
export (AudioStream) var Object_Sonido

var dialogue_data = {}
var interacted_npcs = {}
var current_npc_id = ""
var current_node_id = ""
var current_nodes_dict = {}
var idioma_actual = "Esp"

var is_typing = false
var ultimo_caracter_mostrado: int = 0
var sonido_actual_hablante: AudioStream = null

func _ready():
	AudioS.bus = "Sfx"
	hide()
	cargar_json()
	tween.connect("tween_completed", self, "_on_Tween_completed")
	iniciar_dialogo("GodotIcon", default_object_texture, default_player_texture)

func cargar_json():
	var file = File.new()
	if file.file_exists(DIALOGUE_PATH):
		file.open(DIALOGUE_PATH, File.READ)
		var parse = JSON.parse(file.get_as_text())
		file.close()
		if parse.error == OK:
			dialogue_data = parse.result
		else:
			print("Error al leer JSON de diálogos:", parse.error_string)

func iniciar_dialogo(npc_id: String, spr_object: Texture, spr_player: Texture):
	if not dialogue_data.has(idioma_actual) or not dialogue_data[idioma_actual].has(npc_id):
		print("Diálogo no encontrado para el ID: ", npc_id)
		return

	current_npc_id = npc_id
	if spr_object: object_rect.texture = spr_object
	if spr_player: player_rect.texture = spr_player

	var data_npc = dialogue_data[idioma_actual][npc_id]
	current_nodes_dict = data_npc["nodes"]

	if interacted_npcs.get(npc_id, false):
		current_node_id = data_npc["repeat"]
	else:
		current_node_id = data_npc["initial"]

	show()
	mostrar_nodo_actual()

func mostrar_nodo_actual():
	limpiar_opciones()

	var node = current_nodes_dict[current_node_id]
	var speaker = node["speaker"]

	if speaker == "player":
		sonido_actual_hablante = Player_sonido
	else:
		sonido_actual_hablante = Object_Sonido

	animar_speakers(speaker)
	animar_texto(node["text"])

func animar_speakers(speaker: String):
	var player_is_speaking = (speaker == "player")

	var player_target_scale = SCALE_ACTIVE if player_is_speaking else SCALE_INACTIVE
	var player_target_color = COLOR_ACTIVE if player_is_speaking else COLOR_INACTIVE

	var object_target_scale = SCALE_ACTIVE if not player_is_speaking else SCALE_INACTIVE
	var object_target_color = COLOR_ACTIVE if not player_is_speaking else COLOR_INACTIVE

	tween.interpolate_property(player_rect, "rect_scale", player_rect.rect_scale, player_target_scale, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(player_rect, "modulate", player_rect.modulate, player_target_color, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)

	tween.interpolate_property(object_rect, "rect_scale", object_rect.rect_scale, object_target_scale, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(object_rect, "modulate", object_rect.modulate, object_target_color, TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)

	tween.start()

func animar_texto(texto: String):
	dialogue_label.text = texto
	dialogue_label.percent_visible = 0.0
	is_typing = true
	ultimo_caracter_mostrado = 0

	var duracion = texto.length() * VELOCIDAD_ESCRITURA
	tween.interpolate_property(dialogue_label, "percent_visible", 0.0, 1.0, duracion, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	if not tween.is_connected("tween_step", self, "_on_Tween_step"):
		tween.connect("tween_step", self, "_on_Tween_step")

	tween.start()

func _on_Tween_step(object, key, elapsed, value):
	if object == dialogue_label and key == ":percent_visible":
		var caracteres_visibles = dialogue_label.visible_characters
		if caracteres_visibles > ultimo_caracter_mostrado:
			var caracter_actual = ""
			if caracteres_visibles <= dialogue_label.text.length():
				caracter_actual = dialogue_label.text[caracteres_visibles - 1]
			
			if caracter_actual != " " and caracter_actual != "":
				reproducir_sonido_tipeo()
				
			ultimo_caracter_mostrado = caracteres_visibles

func reproducir_sonido_tipeo():
	if sonido_actual_hablante == null:
		return
		
	var asp = AudioStreamPlayer.new()
	asp.stream = sonido_actual_hablante
	asp.pitch_scale = rand_range(0.95, 1.05)
	
	if AudioS:
		asp.bus = AudioS.bus
		
	add_child(asp)
	asp.play()
	asp.connect("finished", asp, "queue_free")

func _unhandled_input(event):
	if not visible:
		return

	if tiene_opciones_activas():
		return

	if event.is_action_pressed("Interact") and not event.is_echo():
		if not is_typing:
			avanzar_dialogo()

	elif event.is_action_pressed("Especial-Interact") and not event.is_echo():
		if is_typing:
			completar_texto_inmediatamente()
		else:
			avanzar_dialogo()

func completar_texto_inmediatamente():
	if tween.is_connected("tween_step", self, "_on_Tween_step"):
		tween.disconnect("tween_step", self, "_on_Tween_step")

	tween.remove(dialogue_label, "percent_visible")
	dialogue_label.percent_visible = 1.0
	is_typing = false
	evaluar_opciones()

func _on_Tween_completed(object, key):
	if object == dialogue_label and key == ":percent_visible":
		if tween.is_connected("tween_step", self, "_on_Tween_step"):
			tween.disconnect("tween_step", self, "_on_Tween_step")
		is_typing = false
		evaluar_opciones()

func aplicar_estilo_minimalista(btn: Button):
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0)
	style_normal.border_width_left = 1
	style_normal.border_width_right = 1
	style_normal.border_width_top = 1
	style_normal.border_width_bottom = 1
	style_normal.border_color = Color(0.5, 0.5, 0.5, 0.7)
	style_normal.content_margin_left = 14
	style_normal.content_margin_right = 14
	style_normal.content_margin_top = 8
	style_normal.content_margin_bottom = 8

	var style_selected = style_normal.duplicate()
	style_selected.border_color = Color(1.0, 1.0, 1.0, 1.0)
	style_selected.border_width_left = 2
	style_selected.border_width_right = 2
	style_selected.border_width_top = 2
	style_selected.border_width_bottom = 2

	btn.add_stylebox_override("normal", style_normal)
	btn.add_stylebox_override("hover", style_selected)
	btn.add_stylebox_override("focus", style_selected)
	btn.add_stylebox_override("pressed", style_selected)

	btn.add_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	btn.add_color_override("font_color_hover", Color(1, 1, 1, 1))
	btn.add_color_override("font_color_focus", Color(1, 1, 1, 1))

func evaluar_opciones():
	var node = current_nodes_dict[current_node_id]
	if node.has("choices") and node["choices"].size() > 0:
		choices_container.show()
		
		var font_copiada = dialogue_label.get_font("font")
		var botones = []

		for choice in node["choices"]:
			var btn = Button.new()
			btn.text = choice["text"]
			
			if font_copiada:
				btn.add_font_override("font", font_copiada)

			aplicar_estilo_minimalista(btn)

			btn.size_flags_vertical = SIZE_SHRINK_CENTER
			btn.size_flags_horizontal = SIZE_EXPAND_FILL

			btn.connect("pressed", self, "_on_choice_selected", [choice["next"]])

			choices_container.add_child(btn)
			botones.append(btn)

		if botones.size() >= 2:
			botones[0].focus_neighbour_right = botones[1].get_path()
			botones[1].focus_neighbour_left = botones[0].get_path()

		if botones.size() > 0:
			botones[0].call_deferred("grab_focus")

func tiene_opciones_activas() -> bool:
	return choices_container != null and choices_container.get_child_count() > 0 and choices_container.visible

func limpiar_opciones():
	if choices_container:
		choices_container.hide()
		for child in choices_container.get_children():
			child.queue_free()

func avanzar_dialogo():
	if tiene_opciones_activas():
		return

	var node = current_nodes_dict[current_node_id]
	if node.get("next") != null:
		current_node_id = node["next"]
		mostrar_nodo_actual()
	else:
		finalizar_dialogo()

func _on_choice_selected(next_node_id: String):
	current_node_id = next_node_id
	mostrar_nodo_actual()

func finalizar_dialogo():
	interacted_npcs[current_npc_id] = true
	hide()
