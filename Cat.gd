extends Area

export var speed = 10.0

var pathfollow:PathFollow = null
var pathfollow_dir = 1

func _physics_process(delta):
	var newpos = translation
	var dpos = Vector3.ZERO
	if pathfollow:
		pathfollow.offset += delta*speed*pathfollow_dir
		pathfollow.unit_offset = clamp(pathfollow.unit_offset, 0, 1)
		newpos = pathfollow.translation
		dpos = newpos - translation
	if dpos.length_squared() > 0:
		$Model/AnimationPlayer.play("run-loop")
		look_at(newpos, Vector3.UP)
	else:
		$Model/AnimationPlayer.play("idle-loop")
		var player = get_node("../Player")
		look_at(player.translation, Vector3.UP)
	translation = newpos

func _on_Cat_body_entered(_body):
	$Bells.play()

func _on_TriggerCatAppear_body_entered(_body):
	$Bells.play()
	$Meow.play()
	visible = true

func _on_TriggerCatPath_body_entered(_body, nodepath):
	start_path(get_node(nodepath))

func start_path(path:Path):
	var points = path.curve.get_baked_points()
	var point0 = path.to_global(points[0])
	var pointn = path.to_global(points[points.size() - 1])
	var global_translation = to_global(translation)
	var dist0 = point0 - global_translation
	var distn = pointn - global_translation
	pathfollow = path.get_node("PathFollow")
	if distn.length_squared() < dist0.length_squared():
		pathfollow.unit_offset = 1
		pathfollow_dir = -1
	else:
		pathfollow.unit_offset = 0
		pathfollow_dir = 1
	translation = pathfollow.translation
