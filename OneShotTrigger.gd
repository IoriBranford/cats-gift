extends Area

func _ready():
	pass

func _on_OneShotTrigger_body_entered(body):
	queue_free()
