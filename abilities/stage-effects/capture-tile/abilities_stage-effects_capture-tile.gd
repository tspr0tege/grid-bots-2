extends Ability


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	#search in row for a tile that is NOT matching the character and switch it
	#var target = arena.linear_search(caster, "TILE")
	var caster = amx.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": UID,
		"target_type": "TILE",
	}
	var opponent_cg = Data.opposing_group(caster)
	var target = amx.find_arena_tile_in_row_by_control_group(caster.grid_pos, caster.attack_direction, opponent_cg)
	if target == null:
		instructions.can_cast = false
		instructions.reason = "No tile found, for conversion."
		return instructions
	
	instructions.can_cast = true
	instructions.vectors = {"target_coords": target.grid_coordinates}
	instructions.control_group = caster.control_group
	return instructions


func cast(amx : AbilityMethodsExport, instructions: Dictionary) -> void:
	#print(final_instructions)
	$AudioStreamPlayer.play()
	instructions.target._set_control_group(instructions.control_group)
