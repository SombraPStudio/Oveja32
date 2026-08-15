extends StaticBody2D

onready var manta = $Sprite

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player":
		manta.z_index = 3



func _on_Area2D_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player":
		manta.z_index = 0
