extends Ability

const HEAL_10 = preload("res://abilities/buffs/heal-10/object_heal-10.tscn")


func use_ability(caster: Character, arena: Node3D) -> bool:
	if arena._attempt_healing(caster, 10):
		var heal_animation: CPUParticles3D = HEAL_10.instantiate()
		caster.add_child(heal_animation)
		heal_animation.connect("finished", heal_animation.queue_free)
		heal_animation.emitting = true
		return true
	else:
		return false
