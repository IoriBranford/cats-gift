extends Area

export var speed = 20.0

var paths

func _ready():
	visible = false
	paths = get_parent().find_node("Paths")

func _physics_process(delta):
	var pathFollow = get_parent() as PathFollow
	if pathFollow:
		pathFollow.offset += delta*speed
		if pathFollow.unit_offset > 1:
			pathFollow.unit_offset = 1

func reparent(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)

func _on_Cat_body_entered(_body):
	$BellsPlayer.play()

func _on_TriggerCatAppear_body_entered(_body):
	$BellsPlayer.play()
	visible = true

func _on_TriggerCatPath_body_entered(_body, path_number):
	use_pathfollow(path_number)

func use_pathfollow(path_number):
	var pathFollow = paths.find_node("PathFollow%d" % path_number)
	get_parent().remove_child(self)
	pathFollow.add_child(self)
	translation = Vector3.ZERO
	pathFollow.offset = 0
