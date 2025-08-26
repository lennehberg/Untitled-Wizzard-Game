extends State
class_name LockedOnState


const MIN_CAMERA_DISTANCE = 1
const RAY_LENGTH = 100
const FREELOOK_STATE = 1
const LOCK_MIN_DISTANCE = 3
const LOCK_MAX_DISTANCE = 90
const LOCK_MAX_ANGLE = 30.0
const LOCK_MIN_ANGLE = -5.0

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
var enemy_target : CharacterBody3D

var rig : CameraController


func find_enemies_on_screen(screen_size: Vector2, enemies: Array) -> Dictionary:
	var on_screen_enemies : Dictionary = {}
	
	# filter enemies by their position on screen
	for enemy : CharacterBody3D in enemies:
		# project the enemies position onto the viewport
		var unprojected_coordinate : Vector2= camera.unproject_position(enemy.global_position) 
		print(screen_size, unprojected_coordinate)
		if unprojected_coordinate.x < 0 or unprojected_coordinate.x > screen_size.x \
			or unprojected_coordinate.y < 0 or unprojected_coordinate.y > screen_size.y:
				print("skipped")
				continue
		else:
			on_screen_enemies[enemy] = unprojected_coordinate
			print("added")
			
	return on_screen_enemies


func _best_target_helper(enemies: Dictionary, screen_center: Vector2) -> CharacterBody3D:
	var closest_enemy : CharacterBody3D = null 
	var min_distance : float = INF
	var cur_distance : float = 0
	
	# loop through enemies to find the target cloeset to the center
	for enemy in enemies.keys():
		cur_distance = enemies[enemy].distance_to(screen_center)
		# switch min if cur is smaller
		if cur_distance < min_distance:
			min_distance = cur_distance
			closest_enemy = enemy
	
	#print("closest enemy is at ", closest_enemy.global_position)
	return closest_enemy


func find_best_target() -> CharacterBody3D:
	# get the screen size
	var on_screen_enemies = []
	var closest_enemy : CharacterBody3D
	var screen_size = camera.get_viewport().get_visible_rect().size
	# find the center of the screen 
	var screen_center = screen_size / 2
	
	# get all enemies from the tree
	var enemies = camera.get_tree().get_nodes_in_group("enemies")
	
	print(enemies)
	
	# find the enemies which are on the screen
	on_screen_enemies = find_enemies_on_screen(screen_size, enemies)
	
	# find closest enemy to the center and return it
	return _best_target_helper(on_screen_enemies, screen_center)


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
	# get the enemy to lock onto
	enemy_target = find_best_target()
	
	
# rotate the camera around the target
func rotate_on_target():
	var looking_direction = -rig.global_position.direction_to \
		 						(enemy_target.global_position) # might need to be negative
	var target_rotation = atan2(looking_direction.x, looking_direction.z)
	
	var desired_rotation_y = lerp_angle(rig.rotation.y, target_rotation, 0.05)
	
	var clamped_distance = clamp(rig.global_position.distance_to(enemy_target.global_position), \
		LOCK_MIN_DISTANCE, LOCK_MAX_DISTANCE)
		
	var normalized_distance = (clamped_distance - LOCK_MIN_DISTANCE) / (LOCK_MAX_DISTANCE - LOCK_MIN_DISTANCE)
	normalized_distance = smoothstep(0.0, 1.0, normalized_distance)
	
	var angle = lerp(LOCK_MAX_ANGLE, LOCK_MIN_ANGLE, normalized_distance)
	var desired_rotation_x = deg_to_rad(-angle)
	
	rig.rotation.y = lerp(rig.rotation.y, desired_rotation_y, .8)
	rig.rotation.x = lerp(rig.rotation.x, desired_rotation_x, .05)
	
	
# switch the mouse mode from captured to visible
func __switch_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_capture = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_capture = true
	
	
func on_process(delta: float) -> void:
	if enemy_target:
		rotate_on_target()
		
		# attach arm to player, so camera follows player, and dictates direction
		var player_position : Vector3 = player.position
		rig.position = player_position
		rig.position.y = player_position.y + arm_height
	else:
		rig._switch_states(FREELOOK_STATE)
	
	
# Called when an input event is processed by the engine
func on_input(event: InputEvent) -> void: 
	# let mouse move the camera
	if event is InputEventMouseMotion and mouse_capture:
		mouse_input = event.relative * mouse_sensitivity
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and \
			event.pressed:
		__switch_mouse_mode()
