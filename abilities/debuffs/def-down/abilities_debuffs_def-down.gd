extends Ability


func use_ability(caster : Character, arena : Node3D) -> bool:
	#identify a target
	var target = arena.enemy_character
	target.get_node("HpNode").affect_defense(-.1, 10)
	return true
