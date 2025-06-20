extends Ability


func use_ability(caster : Character, arena : Node3D) -> bool:
	#search in row for a tile that is NOT matching the character and switch it
	#var target = arena.linear_search(caster, "TILE")
	var opponent_cg = Data.CGs.RED if caster.control_group == Data.CGs.BLUE else Data.CGs.BLUE
	var target = arena.search_row(caster.grid_pos, caster.attack_direction, arena.for_tile.bind(opponent_cg))
	if target != null:
		target._set_control_group(caster.control_group)
		return true
	else:
		return false
