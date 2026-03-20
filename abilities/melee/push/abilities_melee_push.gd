extends Ability


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster: Character = amx.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": UID,
	}
	#validate tile
	var target_coords = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	if !amx.is_valid_arena_tile(target_coords): 
		instructions.can_cast = false
		instructions.reason = "Nowhere to push to."
		return instructions
	#validate target
	var target: Character = amx.get_character_by_arena_coords(target_coords)
	if target == null: 
		instructions.can_cast = false
		instructions.reason = "No one to push."
		return instructions
	
	if !Data.ability_deck.has(UID):
		Data.ability_deck[UID] = self
	
	instructions.can_cast = true
	instructions.vectors = {
		"target_coords": target_coords,
		"push_to": target_coords + Vector2i(caster.attack_direction, 0)
	}
	return instructions


func cast(amx : AbilityMethodsExport, instructions: Dictionary) -> void:
	#print("BOARD STATE: " + str(arena.arena_tiles))
	var target = amx.get_character_by_arena_coords(instructions.vectors.target_coords)
	amx.execute_move(target, instructions.vectors.push_to, true)
	
