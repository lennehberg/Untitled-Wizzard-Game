# ProjectileEffect.gd
# This is a SpellEffect resource. Its job is to spawn a projectile,
# configure it, wait for it to finish, and then update the spell context.
extends SpellEffect
class_name ProjectileEffect

const HEIGHT_OFFSET = 0.75

## The scene for the projectile to be spawned (must have a Projectile.gd script).
@export var projectile_scene: PackedScene

## The speed at which the projectile will travel in meters per second.
@export var speed: float = 20.0

## The maximum distance the projectile can travel before disappearing.
@export var travel_range: float = 100.0

## Shape and mesh of the projectile, for different spell projectiles
@export var projectile_mesh : Mesh
@export var projectile_shape : Shape3D


# This function is called by the Spellcaster.
func execute(context: Dictionary) -> void:
	# --- 1. Get required data from the context ---
	var caster = context.caster
	if not caster or not projectile_scene:
		print("ProjectileEffect Error: Caster or Projectile Scene not found.")
		effect_finished.emit() # Fail gracefully so the game doesn't crash.
		return

	# --- 2. Instantiate and position the projectile ---
	var projectile: Area3D = projectile_scene.instantiate()
	
	# Get the caster's current position and orientation.
	var spawn_transform = caster.global_transform
	spawn_transform.origin.y += HEIGHT_OFFSET
	projectile.global_transform = spawn_transform
	

	#projectile.look_at(spawn_transform.origin - spawn_transform.basis.z, Vector3.UP)

	# --- 3. Configure the projectile's properties ---
	# We set these properties on the projectile instance itself.
	projectile.speed = speed
	projectile.travel_range = travel_range
	# Set the "caster" as metadata so the projectile knows who to ignore on collision.
	projectile.set("caster", caster) 

	# --- 4. Add to scene and await its signal ---
	# Add the projectile to the main scene tree so it moves independently of the caster.
	caster.get_tree().root.add_child(projectile)
	
	projectile.configure(projectile_mesh, projectile_shape)
	
	# Orient the projectile to face the direction it will travel.
	# This ensures models like arrows or bolts are pointing the right way.
	# For this to work, the projectile model should face its -Z axis by default.
	projectile.look_at(spawn_transform.origin - spawn_transform.basis.z, Vector3.UP)
	
	# This is the core of the async system. We pause execution of this function
	# until the projectile emits its "collided" signal.
	var body_hit = await projectile.collided
	
	# --- 5. Update context and finish ---
	# Once the signal is received, 'body_hit' will contain what we hit (or null).
	# We update the context so subsequent effects (like DamageEffect) know the target.
	context.target = body_hit
	
	# Signal that this effect is done, allowing the Spellcaster to proceed.
	effect_finished.emit()
