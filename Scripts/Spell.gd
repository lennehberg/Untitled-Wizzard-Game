extends Resource

class_name Spell

@export var effects: Array[SpellEffect]

func build_context(caster: CharacterBody3D) -> Dictionary:
	var context = {
		"caster" : caster
	}
	return context
