extends Area

export var speed = 20.0

var pathfollow:PathFollow = null
var pathfollow_dir = 1


func _physics_process(delta):
	var dpos = Vector3.ZERO
	if pathfollow:
		pathfollow.offset += delta*speed*pathfollow_dir
		pathfollow.unit_offset = clamp(pathfollow.unit_offset, 0, 1)
		
		var pos = to_global(translation)
		var dest = pathfollow.to_global(pathfollow.translation)
		var dist = dest - pos
		var velocity = speed * dist.normalized()
		dpos = velocity * delta
		dpos = Vector3(move_toward(pos.x, dest.x, dpos.x), move_toward(pos.y, dest.y, dpos.y), move_toward(pos.z, dest.z, dpos.z))
		look_at(dest, Vector3.UP)
		
	translation += dpos
	if dpos.length_squared() > 1:
		$Model/AnimationPlayer.play("run-loop")
	else:
		$Model/AnimationPlayer.play("idle-loop")

func _on_Cat_body_entered(_body):
	$BellsPlayer.play()

func _on_TriggerCatAppear_body_entered(_body):
	$BellsPlayer.play()
	visible = true

func _on_TriggerCatPath_body_entered(_body, path_number):
	pass

func start_path(path:Path):
	var points = path.curve.get_baked_points()
	var point0 = path.translation + points[0]
	var pointn = path.translation + points[points.size() - 1]
	var dist0 = point0 - translation
	var distn = pointn - translation
	pathfollow = path.get_node("PathFollow")
	if distn.length_squared() < dist0.length_squared():
		pathfollow.unit_offset = 1
		pathfollow_dir = -1
	else:
		pathfollow.unit_offset = 0
		pathfollow_dir = 1
	translation = pathfollow.translation
