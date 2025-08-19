extends CharacterBody3D

# starting health for enemy
@export var health : int = 100

# take damage method, for projectiles and spells thrown which hit the enemy
func take_damage(damage : int) -> void:
	# remove damage from health
	health -= damage
	print("Enemy took ", damage, "damage. current health is", health) # debug print
	
	# if health drops below 0, remove the enemy from the scene
	if health <= 0:
		print("Enemy defeated!") # debug print
		queue_free()
