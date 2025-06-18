extends Ability

const HEAL_10 = preload("res://abilities/buffs/heal-10/object_heal-10.tscn")


func use_ability(caster: Character, arena: Node3D) -> bool:
	var heal_animation: CPUParticles3D = HEAL_10.instantiate()
	caster.add_child(heal_animation)
	heal_animation.connect("finished", heal_animation.queue_free)
	heal_animation.emitting = true
	caster.get_node("HpNode").take_healing(10)
	return true
