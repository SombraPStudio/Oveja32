extends StaticBody2D

onready var nigth_sprite = $Sprite
onready var nigth_timer = $Timer

export (Texture) var off_clock
export (Texture) var on_clock

func _ready():
	clock()

func clock():
	nigth_sprite.texture = off_clock
	nigth_timer.start()
	yield(nigth_timer, "timeout")

	nigth_sprite.texture = on_clock
	nigth_timer.start() 
	yield(nigth_timer, "timeout")
	
	clock() 
