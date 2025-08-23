extends SpringArm3D
class_name CameraController

const MIN_CAMERA_DISTANCE = 1
# array of possible state - default state should be index 0
@export var states : Array[State]

@onready var player : CharacterBody3D = get_parent()
@onready var camera : Camera3D = get_node("Camera3D")

# current state the state machine is running
var cur_state : State
var cur_state_ind : int = 0

enum {EXPLORE, FREELOOK, LOCK_ON}

func _ready() -> void:
	# make sure states have been given to the machine
	if not states:
		print("ERROR: No states given for camera state machine")
		return
		
	# initialize all states
	for state in states:
		state.on_init(self)
	
	# set the current state to the default state, and invoke it's enter method
	cur_state = states[0]
	cur_state.on_enter()
	
	
func _process(delta: float) -> void:
	# invoke the process method of the state
	cur_state.on_process(delta)
	
	
func _physics_process(delta: float) -> void:
	# invoke the physics process method of the state
	cur_state.on_physics_process(delta)
	
	
func _switch_states(new_state: int):
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
	print(global_position)
	
	
func _input(event: InputEvent) -> void:
	# check for state change
	if event.is_action_pressed("switch_ready_state"):
		print("switching states to...")
		# exploration -> freelook, freelook / lock-on -> exploration
		if cur_state_ind == EXPLORE:
			print("freelook")
			_switch_states(FREELOOK)
		else:
			print("explore")
			_switch_states(EXPLORE)
		
	
	if cur_state:
		cur_state.on_input(event)
