extends Ability

const ROCK_CUBE = preload("res://abilities/summons/rock-cube/character_rock-cube.tscn")

func use_ability(caster : Character, arena : Node3D) -> bool:
	var target_tile = arena.get_tile_by_coords(caster.grid_pos + Vector2i(caster.attack_direction, 0))
	if target_tile == null: return false
	if target_tile.occupant: return false #Replace this with damage behavior
	
	var new_rock_cube = ROCK_CUBE.instantiate()
	new_rock_cube.connect("character_death", arena._on_character_death)
	arena.add_child(new_rock_cube)
	arena.place_character_on_board(new_rock_cube, target_tile.grid_coordinates)
	return true
