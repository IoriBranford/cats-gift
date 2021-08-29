extends KinematicBody

var footstepSounds = []

func _ready():
	for i in range(1,18):
		footstepSounds.append(load("res://Sounds/footsteps/%d.ogg" % i) as AudioStreamOGGVorbis)

func _on_Controller_footstep():
	$FootstepPlayer.stop()
	$FootstepPlayer.stream = footstepSounds[randi() % footstepSounds.size()]
	$FootstepPlayer.play()
