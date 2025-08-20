extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = .25

@onready var camera : Camera3D = $CameraRig/Camera3D
@onready var spell_caster : Node = $SpellCaster
@export var player_health : int = 100


var direction : Vector3


func _physics_process(delta: float) -> void:
	# on cast_spell input, tell spellcaster to cast spell
	if Input.is_action_just_pressed("cast_spell"):
		#print("trying to cast spell!")
		print("player position ", global_position)
		spell_caster.cast()
	# set the velocity and the direction the player is facing
	_set_velocity_direction(delta)
	# move the player in the direction and velocity
	move_and_slide()
	# rotate the body to the direction of movement
	turn_to()
	
	
	
	
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


# get the closest enemy to the player
func get_closest_enemy() -> CharacterBody3D:
	# get the group enemies from the scene
	var cur_enemy : CharacterBody3D
	var closest_enemy : CharacterBody3D
	var cur_distance : float
	var min_distance : float
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	if enemies.is_empty():
		return null
	
	# iterate over enemies to find the closest one
	closest_enemy = enemies[0]
	min_distance = global_position.distance_to(closest_enemy.global_position)
	
	for i in range(1, enemies.size()):
		cur_enemy = enemies[i]
		cur_distance = global_position.distance_to(cur_enemy.global_position)
		# if the minimum distance is more the the distance to the current enemy,
		# replace them
		if cur_distance < min_distance:
			closest_enemy = cur_enemy
			min_distance = cur_distance
	
	
	return closest_enemy
