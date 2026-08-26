
extends RefCounted

var arena : Node3D
var match_controller : Node


func _init(new_arena: Node3D, new_match_controller: Node):
	arena = new_arena
	match_controller = new_match_controller


func get_current_energy_level() -> float:
	return match_controller.player_energy


func get_character_by_id(id: String) -> Character:
	return match_controller.characters[id]


func get_character_by_arena_coords(target_coords: Vector2i):
	return arena.get_tile_by_coords(target_coords).occupant


func get_all_on_team(team: MatchSettings.teams) -> Array:
	var target_group := []
	for character in match_controller.characters.values():
		if character.team == team:
			target_group.push_back(character.character_id)
	return target_group


func get_arena_tile_by_coords(coords: Vector2i) -> Node3D:
	return arena.get_tile_by_coords(coords)


func get_all_tiles_in_group(group: MatchSettings.teams) -> Array:
	return arena.tiles_in_group(group)


func add_child_to_arena(object: Node3D) -> void:
	arena.add_child(object)


func add_new_character(character_instructions: Dictionary):
	return match_controller.add_new_character(character_instructions)


func attempt_damage(target_coords: Vector2i, dmg_amt: float) -> bool:
	return match_controller._attempt_damage(target_coords, dmg_amt)


func attempt_ability(caster: Character, ability: Ability):
	return match_controller._attempt_ability(caster, ability)


#func bind_projectile_move(projectile: Projectile) -> Callable:
	#return arena._attempt_move_shot.bind(projectile)
	##_attempt_move_shot(from_coords: Vector2i, to_coords: Vector2i, shot: Projectile)


func execute_move(target: Character, to_coords: Vector2i, pushing := false):
	match_controller._execute_move(target, to_coords, pushing)


func connect_signal_to_arena(signal_source: Node, signal_name: String, handler_function: String) -> void:
	var callback := Callable(match_controller, handler_function)
	if not signal_source.is_connected(signal_name, callback):
		signal_source.connect(signal_name, callback)


func handle_character_death(character: Character) -> void:
	match_controller.handle_character_death(character)


func find_character_by_arena_row(start_coords, search_direction):
	return arena.search_row(start_coords, search_direction, arena.for_character)


func find_arena_tile_in_row_by_team(start_coords: Vector2i, search_direction: int, team: int) -> Node3D:
	return arena.search_row(start_coords, search_direction, arena.for_tile.bind(team))


func is_valid_arena_tile(target_coords) -> bool:
	return arena.is_valid_tile(target_coords)
