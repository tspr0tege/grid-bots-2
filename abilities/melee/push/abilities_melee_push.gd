extends Ability

func use_ability(caster: Character, arena : Node3D) -> bool:
	#validate tile
	var target_coords = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	if !arena.is_valid_tile(target_coords): return false
	#validate target
	var target: Character = arena.get_tile_by_coords(target_coords).occupant
	if target == null: return false
	
	return await arena._execute_move(target, target_coords + Vector2i(caster.attack_direction, 0), true)
