extends Card

const REFLECT = preload("res://cards/counters/reflect/reflect.tscn")

func play_card(caster : Character, arena : Node3D) -> void:
	var new_shield = REFLECT.instantiate()
	new_shield.caster = caster
	new_shield.arena = arena
	caster.get_node("HpNode").connect("received_damage", new_shield._reflect_damage)
	caster.add_child(new_shield)
