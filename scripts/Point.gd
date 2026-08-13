extends Node2D

onready var _sprite: AnimatedSprite = $Sprite

var _is_pressing: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	_sprite.play("idle")

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT) or event is InputEventScreenTouch:
		
		if event.is_pressed() and not _is_pressing:
			_is_pressing = true
			_on_press_started()
			
		elif not event.is_pressed() and _is_pressing:
			_is_pressing = false
			_on_press_released()

func _on_press_started() -> void:
	_sprite.stop()
	_sprite.play("catch")
	
	_disconnect_signals()
	
	_sprite.connect("animation_finished", self, "_on_catch_finished", [], CONNECT_ONESHOT)

func _on_catch_finished() -> void:
	if _sprite.animation == "catch":
		_sprite.frame = 2
		_sprite.playing = false 

func _on_press_released() -> void:
	_disconnect_signals()

	_sprite.play("catch", true) 
	_sprite.connect("animation_finished", self, "_on_reverse_catch_finished", [], CONNECT_ONESHOT)

func _on_reverse_catch_finished() -> void:
	_sprite.play("idle")

func _disconnect_signals() -> void:
	if _sprite.is_connected("animation_finished", self, "_on_catch_finished"):
		_sprite.disconnect("animation_finished", self, "_on_catch_finished")
	if _sprite.is_connected("animation_finished", self, "_on_reverse_catch_finished"):
		_sprite.disconnect("animation_finished", self, "_on_reverse_catch_finished")
