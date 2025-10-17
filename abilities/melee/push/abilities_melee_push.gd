extends Ability


func validate(caster, arena) -> Dictionary:
	instructions.target_type = "OCCUPANT"
	instructions.ability_id = UID
	#validate tile
	var target_coords = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	if !arena.is_valid_tile(target_coords): 
		instructions.can_cast = false
		instructions.reason = "Nowhere to push to."
		return instructions
	#validate target
	var target: Character = arena.get_tile_by_coords(target_coords).occupant
	if target == null: 
		instructions.can_cast = false
		instructions.reason = "No one to push."
		return instructions
	
	if !Data.ability_deck.has(UID):
		Data.ability_deck[UID] = self
	
	instructions.can_cast = true
	instructions.target_coords = target_coords
	instructions.push_to = target_coords + Vector2i(caster.attack_direction, 0)
	return instructions


func cast(arena, final_instructions) -> void:
	arena._execute_move(final_instructions.target, final_instructions.push_to, true)
	
