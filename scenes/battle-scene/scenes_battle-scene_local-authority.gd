extends Node

signal NPC_move
signal NPC_use_ability

@export var ARENA : Arena
@export var MATCH_CONTROLLER : MatchController

#Example arena_state dictionary on server:
##NOTE: Only use these values in LocalAuthority, to maintain logical consistency.
	#{
		#"team": MatchSettings.teams.TEAM_2,
		#"projectiles": [],
		#"traps": [],
		#"occupant": null,
		#"reserved": false,
		#"traversable": true,
		#"state": FloorTile.tile_states.NORMAL,
	#}
var characters = {}
func _new_character() -> Dictionary:
	var new_character := {
		"character_id": "",
		#"start_coords": Vector2i(0,1),
		"grid_coords": Vector2i.ZERO,
		"team": MatchSettings.teams.NEUTRAL,
		"is_animate": true,
		"teleport_enabled": false,
		"diagonal_move_enabled": false,
	}
	return new_character


func generate_character_id() -> String:
	return str(int(floor(randf() * 10000)))


func init_match() -> void:
	MATCH_CONTROLLER.connect("transmit_ability", request_ability)
	MATCH_CONTROLLER.connect("transmit_move", request_move)
	for character in MatchSettings.character_lineup:
		var new_character = _new_character()
		for key in character:
			new_character[key] = character[key]
		if new_character.character_id == "": 
			new_character.character_id = generate_character_id()
			push_error("New character %s was generated without character_id" % new_character.character_id)
		new_character.grid_coords = character.start_coords
		
		print("LocalAuthority.init_match assembled a new character with these details:\n" + str(new_character))
		characters[new_character.character_id] = new_character
	
	MatchSettings.propagate_ability_list(MatchSettings.player_deck)


func request_ability(caster_id: String, ability_id: String) -> void: 
	#MatchSettings.player_character_id
	var ability: Ability = MatchSettings.ability_list[ability_id]
	
	#CANCEL for player with inadequate energy
	if caster_id == MatchSettings.player_character_id and MatchSettings.player_energy < ability.energy_cost: return
	
	var new_instructions = ability.methods.generate_local_instructions(caster_id, self)
	
	if caster_id == MatchSettings.player_character_id: #player ability
		var hand_index = MatchSettings.player_hand.find(ability_id)
		MATCH_CONTROLLER.process_player_ability(hand_index, new_instructions)
	else: #NPC ability
		MATCH_CONTROLLER.execute_ability(new_instructions)


func request_move(character_id: String, to_coords: Vector2i) -> void:
	var character_data = characters.get(character_id)
	#characters[character_id]
	var new_coords = _validate_move(character_data, to_coords)
	#TODO: All move validation that was previously handled by MatchController to be handled in this function, based on match_state and settings, stored here. LocalAuthority needs to fully emulate the server.
	if !(new_coords == character_data.grid_coords):
		character_data.grid_coords = new_coords
		#TODO: Process this based on tick-count


func _validate_move(character: Dictionary, target_coords: Vector2i) -> Vector2i:
	#Check valid coordinates
	#var from_coords = character.grid_coords
	var desired_move = target_coords - character.grid_coords
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if (character.teleport_enabled or desired_move.length() <= 1) and _is_valid_move(character, target_coords):
		MATCH_CONTROLLER._execute_move(character.character_id, target_coords)
		return target_coords
		
	elif (character.diagonal_move_enabled and 
	_is_valid_move(character, character.grid_coords + _move_dir(desired_move, 0))):
		var coords = character.grid_coords + _move_dir(desired_move, 0)
		MATCH_CONTROLLER._execute_move(character.character_id, coords)
		return coords
		
	elif (abs(desired_move.x) <= abs(desired_move.y) and
	 _is_valid_move(character, character.grid_coords + _move_dir(desired_move, 2))):
		var coords = character.grid_coords + _move_dir(desired_move, 2)
		MATCH_CONTROLLER._execute_move(character.character_id, coords)
		return coords
		
	elif _is_valid_move(character, character.grid_coords + _move_dir(desired_move, 1)):
		var coords = character.grid_coords + _move_dir(desired_move, 1)
		MATCH_CONTROLLER._execute_move(character.character_id, coords)
		return coords
	
	else:
		push_warning("LocalAutority received an invalid move request for %s." % character.character_id)
		return character.grid_coords


func _is_valid_move(character: Dictionary, to_coords: Vector2i) -> bool:
	var target_tile = ARENA.get_tile_by_coords(to_coords)
	#Character moving to invalid team tile
	if (character.team != MatchSettings.teams.UNIVERSAL and
	 target_tile.team != character.team): 
		return false
	#Character moving to occupied tile
	if target_tile.occupant: return false
	if target_tile.reserved: return false
	if !target_tile.traversable: return false
	
	#Definitely going to move
	return true


func _move_dir(target_coords: Vector2i, rule: int) -> Vector2i:
	#rule: 0 = diagonal, 1 = favor x, 2 = favor y
	var direction := Vector2i.ZERO
	if target_coords.x != 0 and rule != 2:
		direction.x = target_coords.x / abs(target_coords.x)
	if target_coords.y != 0 and rule != 1:
		direction.y = target_coords.y / abs(target_coords.y)
	return direction
