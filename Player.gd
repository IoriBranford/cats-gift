extends KinematicBody

var footstepSounds = []
var felineLevel = 0

func _ready():
	for i in range(1,18):
		footstepSounds.append(load("res://Sounds/footsteps/%d.ogg" % i) as AudioStreamOGGVorbis)

func _on_Controller_footstep():
	$FootstepPlayer.stop()
	$FootstepPlayer.stream = footstepSounds[randi() % footstepSounds.size()]
	$FootstepPlayer.play()

func _on_Cat_body_entered(_body):
	felineLevel += 1
	match felineLevel:
		1:
			onFelineLevel1()

func onFelineLevel1():
	var we = get_parent().find_node("WorldEnvironment", false) as WorldEnvironment
	we.environment.ambient_light_energy = 8
