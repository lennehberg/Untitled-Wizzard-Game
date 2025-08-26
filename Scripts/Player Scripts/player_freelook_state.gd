extends State
class_name PlayerFreelookState

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = .25

var player : PlayerController
var camera : Camera3D
var spell_caster : Node

@export var player_health : int = 100
var aim_dot : ColorRect

var rotate_with_camera : bool = false
var direction : Vector3


func on_init(_player: PlayerController) -> void:
	if not _player:
		print("Error: player was not passed to init")
		return
	
	player = _player
	camera = _player.camera
	spell_caster = _player.spell_caster
	player_health = _player.player_health
	aim_dot = _player.aim_dot
	
func on_enter() -> void:
	pass
	

func on_physics_process(delta: float) -> void:
	# in freelook state, spell should be able to be cast.
	player._set_velocity_direction(delta)
	player.turn_to()
	player.move_and_slide()
	
	# on cast input, tell spellcaster to cast spell
	if Input.is_action_just_pressed("cast_spell"):
		# TODO look in the direction of the cast / camera
		player.spell_caster.cast()
	
	
