extends Ability


func use_ability(caster : Character, arena : Node3D) -> bool:
	var target = arena.enemy_character if caster == arena.player_character else arena.player_character
	target.get_node("HpNode").affect_defense(-.25, 10)
	return true
