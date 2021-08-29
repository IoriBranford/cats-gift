extends KinematicBody

export var CatPath:NodePath = ""

var Cat
var footstepSounds = []

func _ready():
	Cat = get_node(CatPath)
	Cat.visible = false
	for i in range(1,18):
		footstepSounds.append(load("res://Sounds/footsteps/%d.ogg" % i) as AudioStreamOGGVorbis)

func _on_Controller_footstep():
	$FootstepPlayer.stop()
	$FootstepPlayer.stream = footstepSounds[randi() % footstepSounds.size()]
	$FootstepPlayer.play()

func _on_Cat_body_entered(body):
	if self == body:
		$BellsPlayer.play()

func _on_TriggerCatAppear_body_entered(body):
	if self == body:
		$BellsPlayer.play()
		Cat.visible = true
