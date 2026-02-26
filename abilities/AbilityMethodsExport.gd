class_name AbilityMethodsExport
extends RefCounted

var arena : Node3D
var match_controller : Node


func _init(arena: Node3D, match_controller: Node):
	self.arena = arena
	self.match_controller = match_controller


func get_character_by_id(id: String) -> Character:
	return match_controller.characters[id]


func get_character_by_arena_coords(target_coords: Vector2i):
	return arena.get_tile_by_coords(target_coords).occupant


func get_arena_tile_by_coords(coords: Vector2i):
	return arena.get_tile_by_coords(coords)


func add_child_to_arena(object: Node3D) -> void:
	arena.add_child(object)


func attempt_damage(target_coords: Vector2i, dmg_amt: float) -> bool:
	return match_controller._attempt_damage(target_coords, dmg_amt)


func execute_move(target: Character, to_coords: Vector2i, pushing := false):
	match_controller._execute_move(target, to_coords, pushing)


func connect_signal_to_arena(signal_source: Node, signal_name: String, handler_function: String) -> void:
	var callback := Callable(match_controller, handler_function)
	if not signal_source.is_connected(signal_name, callback):
		signal_source.connect(signal_name, callback)


func find_character_by_arena_row(start_coords, search_direction):
	return arena.search_row(start_coords, search_direction, arena.for_character)


func find_arena_tile_in_row_by_control_group(start_coords: Vector2i, search_direction: int, control_group: int) -> Node3D:
	return arena.search_row(start_coords, search_direction, arena.for_tile.bind(control_group))


func is_valid_arena_tile(target_coords) -> bool:
	return arena.is_valid_tile(target_coords)
