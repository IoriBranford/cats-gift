extends Area

export var Player:NodePath = ""
export var speed = 20.0

var pathFollow:PathFollow = null

func _ready():
	pathFollow = get_parent() as PathFollow

func _process(delta):
	if pathFollow:
		pathFollow.offset += delta
