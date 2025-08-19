extends Resource

class_name SpellEffect

# signal for spell caster to know the effect has finished casting
signal effect_finished

# function to be called when executing a spell cast
# context holds appropriate parameters necessary for casting the spell
func execute(context: Dictionary) -> void:
	# the function will go through the content of context, 
	# and cast the spell accordingly
	effect_finished.emit()
