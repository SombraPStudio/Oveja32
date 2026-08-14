extends Area2D

export (bool) var NeedInteract = false
export (bool) var TpToScene = false
export (PackedScene) var ScenePack
export (NodePath) var TeleportPath

export (float) var OffsetForward = 32.0 

var teleport = null
var Collision = false 
var Body = null

onready var label = $Node2D/Label

func _ready():
	if label:
		label.visible = false

	if TeleportPath and not TeleportPath.is_empty():
		teleport = get_node_or_null(TeleportPath)

func _on_Teleporter_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player":
		Collision = true
		Body = body
		if not NeedInteract:
			_teleport()

func _on_Teleporter_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player":
		Collision = false
		Body = null

func _process(delta):
	if label:
		label.visible = Collision and NeedInteract
	
	if Collision and NeedInteract:
		if Input.is_action_just_pressed("Interact"):
			_teleport()

func _teleport():
	if TpToScene:
		if ScenePack != null:
			get_tree().change_scene_to(ScenePack)
		else:
			print("¡Error! TpToScene está activo pero ScenePack no está asignado.")
	else:
		if teleport != null and Body != null:
			var direccion_frente = Vector2.RIGHT.rotated(teleport.global_rotation)
			
			Body.global_position = teleport.global_position + (direccion_frente * OffsetForward)
		else:
			print("¡Error! No se encontró el nodo destino o el Body es null.")
