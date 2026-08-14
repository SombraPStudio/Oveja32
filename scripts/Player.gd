extends KinematicBody2D

export (int) var velocidad = 250
export (float) var distancia_adelanto = 60.0
export (float, 0.01, 1.0) var suavizado_adelanto = 0.05

var shot_cooldown = 1

var joystick_ref = null
var velocidad_movimiento = Vector2.ZERO

onready var sprite = $Player
onready var camara = $Camera2D

func _ready():
	var UI = get_node_or_null("../CanvasLayer")
	if UI:
		UI.connect("Send_Joystick", self, "_on_Joystick_recibido")
	else:
		print("ADVERTENCIA: No se encontró el CanvasLayer en ../CanvasLayer")

	_configurar_camara()

func _configurar_camara():
	if not has_node("Camera2D"):
		var nueva_camara = Camera2D.new()
		nueva_camara.name = "Camera2D"
		add_child(nueva_camara)
		camara = nueva_camara
	
	camara.current = true
	camara.smoothing_enabled = true
	camara.smoothing_speed = 5.0

func _on_Joystick_recibido(j):
	joystick_ref = j

func _physics_process(delta):
	var dir = Vector2.ZERO
	if joystick_ref and joystick_ref.direccion != Vector2.ZERO:
		dir = joystick_ref.direccion

	if dir != Vector2.ZERO:
		_procesar_animacion(dir)
	else:
		sprite.stop()
		sprite.frame = 0

	_procesar_adelanto_camara(dir)

	velocidad_movimiento = dir * velocidad
	move_and_slide(velocidad_movimiento)

func _procesar_adelanto_camara(dir: Vector2):
	var offset_objetivo = dir * distancia_adelanto
	camara.offset = lerp(camara.offset, offset_objetivo, suavizado_adelanto)

func _procesar_animacion(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		sprite.play("Walk_Side")
		if dir.x > 0:
			sprite.flip_h = false  
		else:
			sprite.flip_h = true  
	else:
		sprite.flip_h = false  
		if dir.y < 0:
			sprite.play("Walk_Up")
		else:
			sprite.play("Walk_Down")
