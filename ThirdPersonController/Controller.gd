extends Spatial

export(NodePath) var PlayerPath  = "" #You must specify this in the inspector!
export(float) var MovementSpeed = 10
export(float) var Acceleration = 3
export(float) var MaxJump = 19
export(float) var MouseSensitivity = 2
export(float) var RotationLimit = 45
export(float) var MaxZoom = 0.5
export(float) var MinZoom = 1.5
export(float) var ZoomSpeed = 2

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
		Direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		Direction.z += 1
	if Input.is_action_pressed("ui_left"):
		Direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		Direction.x += 1
	if Input.is_action_just_pressed("ui_accept"):
		if not IsAirborne:
			CurrentVerticalSpeed = Vector3(0,MaxJump,0)
			IsAirborne = true

	#Rotation
	Player.rotate_y(deg2rad(-Rotation.x)*delta*MouseSensitivity)
#	Player.rotate_y(deg2rad(-Direction.x)*delta*MouseSensitivity)
	InnerGimbal.rotate_x(deg2rad(-Rotation.y)*delta*MouseSensitivity)
	InnerGimbal.rotation_degrees.x = clamp(InnerGimbal.rotation_degrees.x, -RotationLimit, RotationLimit)
	Rotation = Vector2()
	
	#Movement
	var MaxSpeed = MovementSpeed *Direction.normalized()
	Speed = Speed.linear_interpolate(MaxSpeed, delta * Acceleration)
	Movement = Player.transform.basis * (Speed)
	CurrentVerticalSpeed.y += gravity * delta * JumpAcceleration
	Movement += CurrentVerticalSpeed
	Player.move_and_slide(Movement,Vector3.UP)
	if Player.is_on_floor() :
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
