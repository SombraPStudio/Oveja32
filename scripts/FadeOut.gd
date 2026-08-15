extends Control

export (Color) var fade_color

onready var Me = $"."
onready var tween = $Tween
onready var rect = $Color

func _ready():
	Me.visible = true
	rect.color = fade_color
	rect.color.a = 1.0
	rect.visible = true

	tween.interpolate_property(
		rect, 
		"color:a", 
		1.0, 
		0.0, 
		3.5, 
		Tween.TRANS_QUAD, 
		Tween.EASE_IN  
	)
	tween.start()
