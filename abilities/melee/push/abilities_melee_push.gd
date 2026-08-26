extends Ability


func validate(caster_id : String) -> Dictionary:
	var caster: Character = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": ability_id,
	}
	#validate tile
	var target_coords = caster.grid_coords + Vector2i(caster.attack_direction, 0)
	if !MatchSettings.BRIDGE.is_valid_arena_tile(target_coords): 
		instructions.can_cast = false
		instructions.reason = "Nowhere to push to."
		return instructions
	#validate target
	var target: Character = MatchSettings.BRIDGE.get_character_by_arena_coords(target_coords)
	if target == null: 
		instructions.can_cast = false
		instructions.reason = "No one to push."
		return instructions
	
	instructions.can_cast = true
	instructions.vectors = {
		"target_coords": target_coords,
		"push_to": target_coords + Vector2i(caster.attack_direction, 0)
	}
	
	return instructions


func cast(instructions: Dictionary) -> void:
	var target = MatchSettings.BRIDGE.get_character_by_arena_coords(instructions.vectors.target_coords)
	MatchSettings.BRIDGE.execute_move(target, instructions.vectors.push_to, true)
	
