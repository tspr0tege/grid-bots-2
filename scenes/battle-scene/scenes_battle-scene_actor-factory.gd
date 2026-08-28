class_name ActorFactory extends Node

@export var MATCH_CONTROLLER : MatchController


func spawn_character(instructions: Dictionary) -> Character: #return new character
	##EXAMPLE instructions:
	#{
		#"character_id": "6543",
		#"bot_type": "red_test_bot",
		#"role": Data.roles.NPCs,
		#"coords": Vector2i(4, 1),
		#"team": MatchSettings.teams.TEAM_2,
		#"connections": {
			#"attempt_move": "_attempt_move",
			#"search_for_target": "search_for_target",
		#},
	#}
	
	var bot_type = MatchSettings.player_characters[instructions.bot_type]
	var character: Character = load(bot_type).instantiate()
	
	if instructions.role == MatchSettings.roles.PLAYER_CHARACTER:
		MATCH_CONTROLLER.player_character = character
		MatchSettings.player_character_id = instructions.character_id
	
	if instructions.team == MatchSettings.opposing_team(MatchSettings.player_team):
		character.rotation.y = deg_to_rad(-90)
		character.attack_direction = -1
	
	if instructions.has("connections"):
		for signal_name in instructions.connections.keys():
			var function_name = instructions.connections[signal_name]
			character.connect(signal_name, MATCH_CONTROLLER[function_name])
	
	#TODO: assign grid coords in a MatchController move_character function
	character.character_id = instructions.character_id
	character.grid_coords = instructions.start_coords
	character.team = instructions.team
	character.connect("request_ability", MATCH_CONTROLLER.attempt_ability)
	character.connect("character_death", MATCH_CONTROLLER.handle_character_death)
	character.connect("update_grid_coords", MATCH_CONTROLLER.update_character_coords)
	return character


func spawn_projectile() -> void: #return new projectile
	pass
