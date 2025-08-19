extends SpringArm3D

const MIN_CAMERA_DISTANCE = 1

@onready var player : CharacterBody3D = get_parent()
@onready var camera : Camera3D = get_node("Camera3D")

@export var mouse_sensitivity := .5
@export var arm_height = 0.5

var mouse_input : Vector2 = Vector2()
var mouse_capture : bool = true


# Called when the node enteres the scene tree for the first time.
func _ready() -> void:
	# set the spring length to camera position
	spring_length = camera.position.z
	# set the mouse mode to be captured by window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func __rotate_arm_mouse_input() -> void:
	# cap the minimal distance of the camera from the player to avoid clipping
	var dist_to_player = camera.global_position.distance_squared_to(player.global_position)
	
	if dist_to_player < MIN_CAMERA_DISTANCE and mouse_input.y > 0:
		mouse_input.y = 0
		
	# set rotation of spring arm to mouse match mouse inputs
	rotation_degrees.x += mouse_input.y
	rotation_degrees.y += mouse_input.x
	
	# clamp rotation on x to stop camera from flipping
	rotation_degrees.x = clampf(rotation_degrees.x, -40, 50)
		
	# reset mouse input
	mouse_input = Vector2()


# Called every frame. 'delta' is the elapsed time since previous frame
func _process(delta: float) -> void:
	__rotate_arm_mouse_input()
	
	
func __switch_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_capture = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_capture = true
			

# Called when an input event is processed by the engine
func _input(event: InputEvent) -> void: 
	# let mouse move the camera
	if event is InputEventMouseMotion and mouse_capture:
		mouse_input = event.relative * mouse_sensitivity
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and \
			event.pressed:
		__switch_mouse_mode()
		

# Called every physics fps
func _physics_process(delta: float) -> void:
	# attach arm to player, so camera follows player, and dictates direction
	var player_position : Vector3 = player.position
	position = player_position
	position.y = player_position.y + arm_height
		
		
