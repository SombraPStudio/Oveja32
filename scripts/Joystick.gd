extends Area2D

onready var rango = $Rango
onready var palanca = $Palanca
onready var radio = $CollisionShape2D.shape.radius

var direccion = Vector2.ZERO
var touch_index = -1
class_name Joystick

export (float) var margen_extra = 350.0
export (float, 0.0, 1.0) var deadzone = 0.2

var control_activo = false

func _process(delta):
	if touch_index == -1:
		var dir_input = Vector2.ZERO
		
		dir_input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		dir_input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
		var joy_x = Input.get_joy_axis(0, JOY_AXIS_0)
		var joy_y = Input.get_joy_axis(0, JOY_AXIS_1) 
		var joy_vec = Vector2(joy_x, joy_y)
		
		if joy_vec.length() > deadzone and joy_vec.length() > dir_input.length():
			dir_input = joy_vec

		if dir_input.length() > deadzone:
			control_activo = true
			var pos_simulada = global_position + (dir_input.clamped(1) * radio)
			_actualizar_joystick(pos_simulada)
		elif control_activo:
			control_activo = false
			_reset_joystick()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			var dist = global_position.distance_to(event.position)
			if dist <= radio + margen_extra:
				touch_index = event.index
				_actualizar_joystick(event.position)
				
		elif not event.pressed and event.index == touch_index:
			_reset_joystick()

	elif event is InputEventScreenDrag and event.index == touch_index:
		var dist = global_position.distance_to(event.position)
		if dist > radio + margen_extra:
			_reset_joystick()
		else:
			_actualizar_joystick(event.position)

func _actualizar_joystick(pos_dedo):
	var dist = global_position.distance_to(pos_dedo)
	var dir_raw = global_position.direction_to(pos_dedo)
	
	if dist <= radio:
		palanca.global_position = pos_dedo
	else:
		palanca.global_position = global_position + (dir_raw * radio)
	
	direccion = dir_raw * clamp(dist / radio, 0.0, 1.0)

func _reset_joystick():
	touch_index = -1
	palanca.position = Vector2.ZERO
	direccion = Vector2.ZERO
