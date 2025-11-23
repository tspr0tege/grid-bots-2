extends Ability


func validate(caster: Character, arena: Node3D) -> Dictionary:
	#search in row for a tile that is NOT matching the character and switch it
	#var target = arena.linear_search(caster, "TILE")
	instructions.ability_id = UID
	instructions.target_type = "TILE"
	var opponent_cg = Data.opposing_group(caster)
	var target = arena.search_row(caster.grid_pos, caster.attack_direction, arena.for_tile.bind(opponent_cg))
	if target == null:
		instructions.can_cast = false
		instructions.reason = "No tile found, for conversion."
		return instructions
	
	instructions.can_cast = true
	instructions.vectors = {"target_coords": target.grid_coordinates}
	instructions.new_cg = caster.control_group
	return instructions


func cast(_arena: Node3D, final_instructions: Dictionary) -> void:
	#print(final_instructions)
	final_instructions.target._set_control_group(final_instructions.new_cg)
