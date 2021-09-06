extends KinematicBody

export var cat_eye_light_energy = .125
var footstepSounds = []
var felineLevel = 0
onready var ears = get_node("Model/Armature/Skeleton/Ears")
onready var tail = get_node("Model/Armature/Skeleton/Tail")
var game_ended = false

signal game_ended

func _ready():
	ears.visible = false
	tail.visible = false
	for i in range(1,18):
		footstepSounds.append(load("res://sounds/footsteps/%d.ogg" % i) as AudioStreamOGGVorbis)
		
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
	ears.visible = true
	ears.get_node("CPUParticles").restart()
	get_node("LeftEyeSpotlight").light_energy = cat_eye_light_energy
	get_node("RightEyeSpotlight").light_energy = cat_eye_light_energy
	var cat = get_node("../Cat")
	cat.start_path(get_node("../Level/Path2"))

func onFelineLevel2():
	tail.visible = true
	tail.get_node("CPUParticles").restart()
#	$Controller.MaxJump = 25
#	$Controller.MaxFloorAngle = 60
	game_ended = true
	emit_signal("game_ended")
#	$SpotlightGimbal/SpotLight.spot_range = 35

func _on_Controller_movement(movement:Vector3):
	if is_on_floor():
		movement = Vector3(movement.x, 0, movement.z)
		var state_machine = $AnimationTree["parameters/playback"]
		if movement.length_squared() >= 1:
			state_machine.travel("run-loop")
		else:
			state_machine.travel("idle-loop")
