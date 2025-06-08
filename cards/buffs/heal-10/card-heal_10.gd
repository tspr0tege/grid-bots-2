extends Card

const HEAL_10 = preload("res://cards/buffs/heal-10/heal_10.tscn")


func play_card(caster: Character, arena: Node3D) -> void:
	var heal_animation: CPUParticles3D = HEAL_10.instantiate()
	caster.add_child(heal_animation)
	heal_animation.connect("finished", heal_animation.queue_free)
	heal_animation.emitting = true
	caster.get_node("HpNode").take_healing(10)
