extends KinematicBody

var footstepSounds = []
var felineLevel = 0

func _ready():
	$Ears.visible = false
	$Tail.visible = false
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
		2:
			onFelineLevel2()

func onFelineLevel1():
	$Ears.visible = true
	$Ears/CPUParticles.restart()
	var we = get_node("../WorldEnvironment") as WorldEnvironment
	we.environment.ambient_light_energy = 2
	var cat = get_parent().find_node("Cat", true, false)
	cat.use_pathfollow(3)

func onFelineLevel2():
	$Tail.visible = true
	$Tail/CPUParticles.restart()
	$Controller.MaxJump = 25
	$SpotLight.spot_range = 35
