extends Node

@export var ARENA : Node3D


func place_character_on_board(instructions: Dictionary):
	var character = load(instructions.model).instantiate()
	var target_tile = ARENA.get_tile_by_coords(instructions.coords)
	
	match instructions.role:
		Data.roles.PLAYER_CHARACTER:
			$"../MatchController".player_character = character
		Data.roles.OPPOSING_PLAYER:
			character.rotation.y = deg_to_rad(-90)
			character.attack_direction = -1
			
			
		Data.roles.NPCs:
			pass
		_:
			push_error("Attempting to instantiate a new character in the arena without a role specified in the instructions. Dumping Character: " + str(instructions))
			return null
	
	if instructions.has("connections"):
		for signal_name in instructions.connections.keys():
			var function_name = instructions.connections[signal_name]
			character.connect(signal_name, $"../MatchController"[function_name])
	
	character.grid_pos = instructions.coords
	character.position = target_tile.position
	character.control_group = instructions.control_group
	character.connect("request_ability", $"../MatchController"._attempt_ability)
	character.connect("character_death", $"../MatchController".handle_character_death)
	ARENA.add_child(character)
	target_tile.add_occupant(character)
	return character
