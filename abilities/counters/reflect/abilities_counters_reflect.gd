extends Ability

const REFLECT = preload("res://abilities/counters/reflect/object_reflect.tscn")

func use_ability(caster : Character, arena : Node3D) -> bool:
	var new_shield = REFLECT.instantiate()
	new_shield.caster = caster
	new_shield.arena = arena
	caster.get_node("HpNode").connect("received_damage", new_shield._reflect_damage)
	caster.add_child(new_shield)
	return true
