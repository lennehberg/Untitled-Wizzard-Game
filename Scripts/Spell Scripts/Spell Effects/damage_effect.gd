extends SpellEffect

class_name DamageEffect

@export var damage_amount : int = 10

func execute(context: Dictionary):
	# get the target from context, and apply damage to it
	if context.target:
		var target = context.target
		if target:
			if target.has_method("take_damage"):
				target.take_damage(damage_amount)
	effect_finished.emit()
