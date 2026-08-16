extends Node2D

signal night_Finish(Bool)

onready var nightstand = $World/nightstand
onready var player = $Player

func _ready():
	player.tipyngtext("Deberia apagar la alarma...", 2)
	emit_signal("night_Finish",nightstand)
