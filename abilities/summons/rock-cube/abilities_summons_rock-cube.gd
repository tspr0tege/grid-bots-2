extends Ability

const ROCK_CUBE = preload("res://abilities/summons/rock-cube/character_rock-cube.tscn")

func use_ability(caster : Character, arena : Node3D) -> bool:
	print("Casting Rock Cube")
	var rock_cube_pos = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	
	if !arena.is_valid_tile(rock_cube_pos):
		print("Attempting to place Rock Cube outside of arena limits. Canceled")
		return false
	if arena.arena_tiles[rock_cube_pos.y][rock_cube_pos.x].occupant:
		print("Attempting to place Rock Cube in an occupied space. Canceled")
		return false
	
	var new_rock_cube = ROCK_CUBE.instantiate()
	arena.add_child(new_rock_cube)
	arena.place_character_on_board(new_rock_cube, rock_cube_pos)
	return true
