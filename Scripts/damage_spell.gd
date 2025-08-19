extends Spell
class_name DamageSpell


func build_context(caster: CharacterBody3D) -> Dictionary:
	# use spell_caster's methods to find the closest enemy to spell caster
	#var spell_caster = caster.get_node("SpellCaster")
	print("building context for damage spell...")
	var closest_enemy = caster.get_closest_enemy()
	
	return {
		"target" : closest_enemy
	}
