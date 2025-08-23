extends Area3D
class_name Projectile

# signal to notify when projectiles collides with a body
signal collided(body)

@onready var caster : CharacterBody3D = get("caster")
@onready var mesh_instance : MeshInstance3D = $MeshInstance3D
@onready var collision_shape : CollisionShape3D = $CollisionShape3D

var speed : float = 20.0
var travel_range : float = 100.0

var _distance_traveled : float = 0.0


func configure(p_mesh: Mesh, p_shape: Shape3D):
	# apply given resources to the projectile
	mesh_instance.mesh = p_mesh
	collision_shape.shape = p_shape
	

func _physics_process(delta: float) -> void:
	# get distance to move
	var distance_to_move = speed * delta
	# move forward base on caster's transform
	global_position +=  -global_transform.basis.z * distance_to_move
	
	# update the distance traveled
	_distance_traveled += distance_to_move
	#print(global_position)
	if _distance_traveled > travel_range:
		# remove the object from the queue, and notify
		# the spellcaster that the effect is over
		queue_free()
		collided.emit(null)
	
		
func _on_body_entered(body):
	# ignore hitting the caster
	if body == caster:
		return
	
	collided.emit(body)
	queue_free()
		
