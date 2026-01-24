extends Ability

const ROCK_CUBE = preload("res://abilities/summons/rock-cube/character_rock-cube.tscn")


func validate(caster, arena) -> Dictionary:
	instructions.target_type = "TILE"
	instructions.ability_id = UID
	var target_tile = arena.get_tile_by_coords(caster.grid_pos + Vector2i(caster.attack_direction, 0))
	if target_tile == null: 
		instructions.can_cast = false
		instructions.reason = "No valid tile available in front of caster."
		return instructions
	
	if target_tile.occupant: #Replace this with damage behavior
		instructions.can_cast = false
		instructions.reason = "Target tile is occupied."
		return instructions
		
	instructions.can_cast = true
	instructions.vectors = {"target_coords": target_tile.grid_coordinates}
	
	return instructions


func cast(arena, final_instructions) -> void:
	var new_rock_cube = ROCK_CUBE.instantiate()
	new_rock_cube.connect("character_death", arena._on_character_death)
	arena.add_child(new_rock_cube)
	arena.place_character_on_board(new_rock_cube, final_instructions.target.grid_coordinates)
