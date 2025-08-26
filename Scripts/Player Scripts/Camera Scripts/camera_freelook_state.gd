extends State
class_name FreelookState

const MIN_CAMERA_DISTANCE = 1
const RAY_LENGTH = 100

var camera : Camera3D
var player : CharacterBody3D

@export var spring_length : float = 1.5
@export var mouse_sensitivity := .5
@export var arm_height = 0.65
@export var x_offset = -0.5

var aim_dot : ColorRect
var mouse_input : Vector2 = Vector2()
var mouse_capture : bool = true
var space_state : PhysicsDirectSpaceState3D

var rig : CameraController



func on_init(camera_controller):
	rig = camera_controller
	camera = rig.camera
	player = rig.player
	space_state = rig.get_world_3d().direct_space_state
	aim_dot = player.aim_dot


# Called when the node enteres the scene tree for the first time.
func on_enter() -> void:
	# set the spring length to camera position
	rig.spring_length = spring_length
	# set the mouse mode to be captured by window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#rig.global_position.x += 200
	aim_dot.visible = true
	

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
	camera.position.x += x_offset # didnt work for a while and now it does
	
	# start a raycast to detect enemies in front of camera
	var ray_origin = camera.global_position
	var ray_end = ray_origin - camera.global_basis.z * RAY_LENGTH
	
	# query the physics space for a ray cast
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	# check if the ray hit an enemy
	if result:
		if result.collider.is_in_group("enemies"): # if collider detected enemy
			aim_dot.color = Color.RED
		else:
			aim_dot.color = Color.WHITE
	else:
		aim_dot.color = Color.WHITE
		
func on_exit() -> void:
	pass
