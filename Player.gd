extends KinematicBody

var footstepSounds = []
var felineLevel = 0
var camera_hit_wall = false

func _ready():
	$Ears.visible = false
	$Tail.visible = false
	for i in range(1,18):
		footstepSounds.append(load("res://sounds/footsteps/%d.ogg" % i) as AudioStreamOGGVorbis)
	$Model/AnimationPlayer.play("idle-loop")

func _process(delta):
	if camera_hit_wall:
		camera_hit_wall = false
	else:
		$Model.visible = true
		
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
	we.environment.ambient_light_energy = 16
	var cat = get_node("../Cat")
	cat.start_path(get_node("../Level/Path2"))

func onFelineLevel2():
	$Tail.visible = true
	$Tail/CPUParticles.restart()
	$Controller.MaxJump = 25
	$Controller.MaxFloorAngle = 60
	$SpotLight.spot_range = 35

func _on_Controller_camera_hit_wall():
	camera_hit_wall = true
	$Model.visible = false
