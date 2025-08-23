extends State
class_name ExplorationState

const MIN_CAMERA_DISTANCE = 1

var camera : Camera3D
var player : CharacterBody3D

@export var spring_length : float = 2.0
@export var mouse_sensitivity := .5
@export var arm_height = 0.5

var mouse_input : Vector2 = Vector2()
var mouse_capture : bool = true

var rig : CameraController


func on_init(camera_controller: CameraController):
	rig = camera_controller
	camera = rig.camera
	player = rig.player


# Called when the node enteres the scene tree for the first time.
func on_enter() -> void:
	# set the spring length to camera position
	rig.spring_length = spring_length
	# set the mouse mode to be captured by window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# rotate arm based on mouse input
func __rotate_arm_mouse_input() -> void:
	# cap the minimal distance of the camera from the player to avoid clipping
	var dist_to_player = camera.global_position.distance_squared_to(player.global_position)
	
	if dist_to_player < MIN_CAMERA_DISTANCE and mouse_input.y > 0:
		mouse_input.y = 0
		
	# set rotation of spring arm to mouse match mouse inputs
	rig.rotation_degrees.x += mouse_input.y
	rig.rotation_degrees.y += mouse_input.x
	
	# clamp rotation on x to stop camera from flipping
	rig.rotation_degrees.x = clampf(rig.rotation_degrees.x, -40, 50)
		
	# reset mouse input
	mouse_input = Vector2()


# Called every frame. 'delta' is the elapsed time since previous frame
func on_process(delta: float) -> void:
	__rotate_arm_mouse_input()


# switch the mouse mode from captured to visible
func __switch_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_capture = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_capture = true
			


# Called when an input event is processed by the engine
func on_input(event: InputEvent) -> void: 
	# let mouse move the camera
	if event is InputEventMouseMotion and mouse_capture:
		mouse_input = event.relative * mouse_sensitivity
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and \
			event.pressed:
		__switch_mouse_mode()
		


# Called every physics fps
func on_physics_process(delta: float) -> void:
	# attach arm to player, so camera follows player, and dictates direction
	var player_position : Vector3 = player.position
	rig.position = player_position
	rig.position.y = player_position.y + arm_height
		
		
