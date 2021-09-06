extends Spatial

#const Tightrope = preload("res://Tightrope.gd")

export(NodePath) var PlayerPath  = "" #You must specify this in the inspector!
export(float) var MovementSpeed = 10
export(float) var Acceleration = 10
export(float) var MaxJump = 10
export(float) var MouseSensitivity = 2
export(float) var RotationLimit = 45
export(float) var MaxZoom = 0.5
export(float) var MinZoom = 1.5
export(float) var ZoomSpeed = 2
export var MaxFloorAngle = PI/4

var Player
var InnerGimbal
var Rotation = Vector2()
var gravity = -10
var Movement = Vector3()
var ZoomFactor = MaxZoom
var ActualZoom = MaxZoom
var Speed = Vector3()
var CurrentVerticalSpeed = Vector3()
var JumpAcceleration = 3
var IsAirborne = false
var footstepTimer = 0

signal footstep
signal movement
signal camera_hit_wall

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Player = get_node(PlayerPath)
	InnerGimbal =  $InnerGimbal

func _unhandled_input(event):
	if event is InputEventMouseMotion :
		Rotation += event.relative
	
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				ZoomFactor -= 0.05
			BUTTON_WHEEL_DOWN:
				ZoomFactor += 0.05
		ZoomFactor = clamp(ZoomFactor, MaxZoom, MinZoom)
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_ESCAPE:
				get_tree().quit()

func _physics_process(delta):
	var Direction = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		Direction.z += 1
	if Input.is_action_pressed("ui_down"):
		Direction.z -= 1
	if Input.is_action_pressed("ui_left"):
		Direction.x += 1
	if Input.is_action_pressed("ui_right"):
		Direction.x -= 1
	if Input.is_action_just_pressed("ui_accept"):
		if not IsAirborne:
			CurrentVerticalSpeed = Vector3(0,MaxJump,0)
			IsAirborne = true
			emit_signal("footstep")

	#Rotation
	Player.rotate_y(deg2rad(-Rotation.x)*delta*MouseSensitivity)
#	Player.rotate_y(deg2rad(-Direction.x)*delta*MouseSensitivity)
	InnerGimbal.rotate_x(deg2rad(Rotation.y)*delta*MouseSensitivity)
	InnerGimbal.rotation_degrees.x = clamp(InnerGimbal.rotation_degrees.x, -RotationLimit, RotationLimit)
	Rotation = Vector2()
	
	#Movement
	var MaxSpeed = MovementSpeed *Direction.normalized()
	Speed = Speed.linear_interpolate(MaxSpeed, delta * Acceleration)
	Movement = Player.transform.basis * (Speed)
	CurrentVerticalSpeed.y += gravity * delta * JumpAcceleration
	Movement += CurrentVerticalSpeed
	emit_signal("movement", Movement)
	
	var tightrope
	var tightropepoint
#	if $RayCast.is_colliding():
#		tightrope = $RayCast.get_collider() as Tightrope
#		if tightrope:
#			tightropepoint = $RayCast.get_collision_point()
#			Player.translation = tightropepoint
#			var vec = Vector3.FORWARD
#			vec = vec.rotated(Vector3.RIGHT, tightrope.rotation.x)
#			vec = vec.rotated(Vector3.UP, tightrope.rotation.y)
#			vec = vec.rotated(Vector3.FORWARD, tightrope.rotation.z)
#			Movement = Movement.dot(vec) * vec

	var wasOnFloor = Player.is_on_floor()
	Player.move_and_slide(Movement,Vector3.UP, false, 4, MaxFloorAngle)
	if Player.is_on_floor() :
		if not wasOnFloor:
			emit_signal("footstep")
		CurrentVerticalSpeed.y = 0
		IsAirborne = false

		var speed = Speed.length()
		if speed >= 1:
			footstepTimer += delta
			var footstepInterval = clamp(1 - speed/MovementSpeed, 0.25, 0.75)
			if footstepTimer >= footstepInterval:
				emit_signal("footstep")
				footstepTimer = 0
		else:
			footstepTimer = 0

	#Zoom
	ActualZoom = lerp(ActualZoom, ZoomFactor, delta * ZoomSpeed)
	InnerGimbal.set_scale(Vector3(ActualZoom,ActualZoom,ActualZoom))

	var raycast = $InnerGimbal/RayCast
	var camera = $InnerGimbal/Camera
	var camerapos
	if raycast.is_colliding():
		camerapos = raycast.get_collision_point()
		emit_signal("camera_hit_wall")
	else:
		camerapos = raycast.to_global(-raycast.cast_to)
	camera.translation = camera.to_local(camerapos)

#func _on_TightropeDetector_body_entered(body):
#	var tightrope = body as Tightrope
#	if tightrope:
#		var vec = Vector3.FORWARD
#		vec = vec.rotated(Vector3.RIGHT, tightrope.rotation.x)
#		vec = vec.rotated(Vector3.UP, tightrope.rotation.y)
#		vec = vec.rotated(Vector3.FORWARD, tightrope.rotation.z)
		
