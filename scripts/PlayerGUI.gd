extends CanvasLayer

signal Send_Joystick(j)

onready var joystick = $"HUD/Joystick(control)/Joystick"
onready var pos_original: Vector2 = joystick.global_position

var oculto: bool = false

func _ready():
	emit_signal("Send_Joystick", joystick)

	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	
	var hay_mando = Input.get_connected_joypads().size() > 0
	var es_tactil = OS.has_feature("mobile") or OS.has_touchscreen_ui_hint()
	
	_alternar_joystick(hay_mando or not es_tactil)

func _input(event):

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		if event is InputEventMouseMotion and event.relative.length() < 1.0:
			return
		_alternar_joystick(true)

	elif event is InputEventJoypadButton:
		_alternar_joystick(true)
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.25:
			_alternar_joystick(true)

	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		_alternar_joystick(false)

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		_alternar_joystick(true)

func _alternar_joystick(debe_ocultar: bool):
	return
	if oculto == debe_ocultar:
		return
		
	oculto = debe_ocultar
	joystick.visible = not debe_ocultar
	
	if debe_ocultar:
		joystick.global_position = Vector2(-9999, -9999)
	else:
		joystick.global_position = pos_original
	oculto = debe_ocultar
	joystick.visible = not debe_ocultar
	
	if debe_ocultar:
		joystick.global_position = Vector2(-9999, -9999)
	else:
		joystick.global_position = pos_original

