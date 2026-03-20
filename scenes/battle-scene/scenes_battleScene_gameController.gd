extends Node3D


const FLOOR_TILE = preload("res://scenes/battle-scene/floor_tile.tscn")
const PLAYER_CHARACTER = preload("res://entities/test-character/player_character.tscn")
const RED_CHARACTER = preload("res://entities/test-character/red_character.tscn")

var grid_size = Vector2i(6, 3)

var arena_tiles : Array = []

func _ready():
	init_arena_tiles()
	#SceneManager.load_combatants(self)


func init_arena_tiles():
	arena_tiles = []
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			var new_tile = FLOOR_TILE.instantiate()
			new_tile.position = Vector3((1.1 * x) + .55, 0, (1.1 * y) + .55)
			new_tile.grid_coordinates = Vector2i(x, y)
			#arena_tiles_dict = new_tile
			new_tile.remove_occupant()
			if (x < grid_size.x / 2):
				new_tile._set_control_group(Data.player_control_group)
			else:
				new_tile._set_control_group(Data.opposing_group(Data.player_control_group))
			$Floor.add_child(new_tile)
			row.append(new_tile)
			
		arena_tiles.append(row)


func move_dir(target_pos: Vector2i, rule: int) -> Vector2i:
	#rule: 0 = diagonal, 1 = favor x, 2 = favor y
	var direction := Vector2i.ZERO
	if target_pos.x != 0 and rule != 2:
		direction.x = target_pos.x / abs(target_pos.x)
	if target_pos.y != 0 and rule != 1:
		direction.y = target_pos.y / abs(target_pos.y)
	return direction


func is_valid_move(character: Character, to_pos: Vector2i) -> bool:
	#Check Character controlled tile
	var target_tile = get_tile_by_coords(to_pos)
	if target_tile == null: return false
	#Character moving to invalid control_group tile
	if character.control_group != Data.CGs.UNIVERSAL and target_tile.control_group != character.control_group: return false
	#Character moving to occupied tile
	if target_tile.occupant and !is_instance_of(character, Obstacle): return false
	
	#Definitely going to move
	return true


func search_row(coords: Vector2i, direction: int, search_for: Callable) -> Node3D:
	var target_row = coords.y
	var start_point = coords.x + direction
	var end_point = grid_size.x if direction > 0 else 0
	var search_selection = arena_tiles[target_row].slice(start_point, end_point, direction)
	if end_point == 0: search_selection.push_back(arena_tiles[target_row][0])
	
	for tile in search_selection:
		var found = search_for.call(tile)
		if found: return found
	
	return null


func search_col(col_number: int, search_for: Callable) -> Node3D:
	for i in range(3):
		var found = search_for.call(arena_tiles[col_number][i])
		if found: return found
	
	return null


func for_tile(target_tile: Node3D, control_group: Data.CGs) -> Node3D:
	if target_tile.control_group == control_group:
		return target_tile
	else:
		return null


func for_character(target_tile: Node3D) -> Character:
	return target_tile.occupant


func tiles_in_group(control_group: Data.CGs) -> Array:
	var matching_tiles := []
	
	for row in arena_tiles:
		for tile in row:
			if tile.control_group == control_group:
				matching_tiles.push_back(tile)
	
	return matching_tiles


func is_valid_tile(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= grid_size.x: return false
	if pos.y < 0 or pos.y >= grid_size.y: return false
	
	var target_tile = arena_tiles[pos.y][pos.x]
	if target_tile == null: return false
		
	return true


func get_tile_by_coords(coords: Vector2i) -> Node3D:
	if !is_valid_tile(coords): return null
	else: return arena_tiles[coords.y][coords.x]


func _attempt_move_shot(from_coords: Vector2i, to_coords: Vector2i, shot: Projectile) -> void:
	var current_tile = get_tile_by_coords(from_coords)
	current_tile.remove_shot(shot.shots_index)
	#shot.grid_coords = to_coords
	var new_tile = get_tile_by_coords(to_coords)
	if new_tile:
		new_tile.add_shot(shot)
	else:
		shot.exit_arena()
		return
