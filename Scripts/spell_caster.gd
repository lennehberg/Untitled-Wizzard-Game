extends Node

@export var spells : Array[Spell]
@export var spell_index: int = 0

@onready var caster: CharacterBody3D = get_parent()

@onready var global_position = caster.global_position

func cast():
	print("starting spell cast...")
	# cast the spell that is currently selected
	var cur_spell = spells[spell_index]
	print(cur_spell)
	# build context for spell to cast
	var spell_context = cur_spell.build_context(caster)
	print("context built " ,spell_context)
	# iterate through spell's spell effects and execute each one
	for spell_effect in cur_spell.effects:
		print("applying spell effect...", spell_effect)
		spell_effect.execute(spell_context)
		await spell_effect.effect_finished
	
	
