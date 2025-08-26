extends CharacterBody3D
class_name PlayerController

enum {EXPLORE, FREELOOK, LOCK_ON}

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = .25

@export var states : Array[State]
var cur_state : State
var cur_state_ind : int = 0

@onready var camera : Camera3D = $CameraRig/Camera3D
@onready var spell_caster : Node = $SpellCaster

@export var player_health : int = 100
@export var aim_dot : ColorRect

var rotate_with_camera : bool = false
var direction : Vector3


# set the velocity of the player for move_and_slide
func _set_velocity_direction(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)) * input_dir.length()
	direction = Vector3(direction.x, 0, direction.z).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		
		
# turn the character model to the direction it is moving
func turn_to() -> void:
	if direction.length() > 0:
		var yaw := atan2(-direction.x, -direction.z)
		yaw = lerp_angle(rotation.y, yaw, ROTATION_SPEED)
		rotation.y = yaw


func _ready() -> void:
	# gracefully fail if no states
	if not states:
		print("ERROR: No states available for player")
		return
	
	# init all states
	for state in states:
		state.on_init(self)
		
	# enter the default state (EXPLORE)
	cur_state = states[EXPLORE]
	cur_state.on_enter()


func _process(delta: float) -> void:
	cur_state.on_process(delta)
	
	
func _physics_process(delta: float) -> void:
	cur_state.on_physics_process(delta)
	
	
func _switch_state(new_state: int):
		# value safety
	if new_state < 0 or new_state >= states.size():
		return 
	
	# exit the current state
	cur_state.on_exit()
	# switch current state to new state
	cur_state = states[new_state]
	cur_state_ind = new_state
	# start new state
	cur_state.on_enter()
	
	
func _input(event: InputEvent) -> void:
	var is_ready_input = event.is_action_pressed("switch_ready_state")
	var is_lock_input = event.is_action_pressed("switch_lock_on_state")
	match cur_state_ind:
		# if player is in explore mode, switch to given mode
		EXPLORE:
			if is_ready_input:
				_switch_state(FREELOOK)
			elif is_lock_input:
				_switch_state(LOCK_ON)
		# if player is in freelook
		FREELOOK:
			# if input is freelook again, switch back to explore
			if is_ready_input: 
				_switch_state(EXPLORE) 
			elif is_lock_input:
				_switch_state(LOCK_ON)
		# if player is in lock-on
		LOCK_ON:
			# switch to freelook on input
			if is_ready_input:
				_switch_state(FREELOOK)
			elif is_lock_input:
				_switch_state(EXPLORE)
		
	
