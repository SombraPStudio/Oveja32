extends StaticBody2D

onready var nigth_sprite = $Sprite
onready var nigth_timer = $Timer
onready var  AudiosS = $AudioStreamPlayer2D
onready var Interact = $Interact

export (Texture) var off_clock
export (Texture) var on_clock

export (AudioStream) var ClockTheme

var collicion = false
var Stopped = false

func _ready():
	AudiosS.bus = "Sfx"
	AudiosS.stream = ClockTheme
	
	if ClockTheme is AudioStreamMP3:
		ClockTheme.loop = true

	AudiosS.play()
	clock()

func clock():
	if Stopped:
		return
	nigth_sprite.texture = off_clock
	nigth_timer.start()
	yield(nigth_timer, "timeout")
	if Stopped:
		return
	nigth_sprite.texture = on_clock
	nigth_timer.start() 
	yield(nigth_timer, "timeout")
	if Stopped:
		return
	clock() 


func _on_InteractZone_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player":
		if !Stopped:
				Interact.visible = true
		collicion = true

func _on_InteractZone_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player":
		Interact.visible = false
		collicion = false

func StopAlarm():
	nigth_sprite.texture = off_clock
	AudiosS.stop()

func _process(delta):
	if collicion:
		if Input.is_action_just_pressed("Interact"):
			Stopped = true
			Interact.visible = false
			StopAlarm()
