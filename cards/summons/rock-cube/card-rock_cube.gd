extends Card

const ROCK_CUBE = preload("res://cards/summons/rock-cube/rock_cube.tscn")

func play_card(caster : Character, arena : Node3D) -> void:
	print("Casting Rock Cube")
	var rock_cube_pos = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	
	if !arena.is_valid_tile(rock_cube_pos):
		print("Attempting to place Rock Cube outside of arena limits. Canceled")
		return
	if arena.board_state[rock_cube_pos.y][rock_cube_pos.x].occupant:
		print("Attempting to place Rock Cube in an occupied space. Canceled")
		return
	
	var new_rock_cube = ROCK_CUBE.instantiate()
	arena.add_child(new_rock_cube)
	arena.place_character_on_board(new_rock_cube, rock_cube_pos)
