class_name Arena extends Node3D

const FLOOR_TILE = preload("res://scenes/battle-scene/floor_tile.tscn")
var grid_size = Vector2i(6, 3)
var arena_tiles : Array = []


func _ready():
	if MatchSettings.is_online_match:
		process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		process_mode = Node.PROCESS_MODE_PAUSABLE
	
	init_arena_tiles()


func init_arena_tiles():
	arena_tiles = []
	#TODO: Fix the x/y order of the array. This is for visual convenience, but the array is never laid out visually anyway.
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			var new_tile = FLOOR_TILE.instantiate()
			new_tile.position = Vector3((1.1 * x) + .55, 0, (1.1 * y) + .55)
			new_tile.grid_coordinates = Vector2i(x, y)
			#new_tile.remove_occupant()
			if (x < grid_size.x / 2):
				new_tile.set_team(MatchSettings.player_team)
			else:
				new_tile.set_team(MatchSettings.opposing_team(MatchSettings.player_team))
			$Floor.add_child(new_tile)
			row.append(new_tile)
			
		arena_tiles.append(row)


func is_valid_move(character: Character, to_coords: Vector2i) -> bool:
	#Check Character controlled tile
	var target_tile = get_tile_by_coords(to_coords)
	if target_tile == null: return false
	#Character moving to invalid team tile
	if character.team != MatchSettings.teams.UNIVERSAL and target_tile.team != character.team: return false
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
		var found = search_for.call(arena_tiles[i][col_number])
		if found: return found
	
	return null


func for_tile(target_tile: Node3D, team: MatchSettings.teams) -> Node3D:
	if target_tile.team == team:
		return target_tile
	else:
		return null


func for_character(target_tile: Node3D) -> Character:
	return target_tile.occupant


func tiles_in_group(team: MatchSettings.teams) -> Array:
	var matching_tiles := []
	
	for row in arena_tiles:
		for tile in row:
			if tile.team == team:
				matching_tiles.push_back(tile)
	
	return matching_tiles


func is_valid_tile(coords: Vector2i) -> bool:
	if coords.x < 0 or coords.x >= grid_size.x: return false
	if coords.y < 0 or coords.y >= grid_size.y: return false
	if arena_tiles[coords.y][coords.x] == null: return false
	
	return true


func get_tile_by_coords(coords: Vector2i) -> Node3D:
	if !is_valid_tile(coords): return null
	else: return arena_tiles[coords.y][coords.x]
