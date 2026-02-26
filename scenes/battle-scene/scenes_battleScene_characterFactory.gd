extends Node

@export var ARENA : Node3D

const PLAYER_CHARACTER = preload("res://entities/test-character/player_character.tscn")
const RED_CHARACTER = preload("res://entities/test-character/red_character.tscn")


func place_character_on_board(instructions: Dictionary):
	var character = load(instructions.model).instantiate()
	var target_tile = ARENA.get_tile_by_coords(instructions.coords)
	
	match instructions.role:
		Data.roles.PLAYER_CHARACTER:
			$"../MatchController".player_character = character
		Data.roles.OPPOSING_PLAYER:
			pass
		Data.roles.NPCs:
			for signal_key in instructions.connections.keys():
				character.connect(signal_key, $"../MatchController"[instructions.connections[signal_key]])
		_:
			push_error("Attempting to instantiate a new character in the arena without a role specified in the instructions. Dumping Character: " + str(instructions))
			return null
	
	character.grid_pos = instructions.coords
	character.position = target_tile.position
	character.connect("request_ability", $"../MatchController"._attempt_ability)
	ARENA.add_child(character)
	target_tile.add_occupant(character)
	return character
