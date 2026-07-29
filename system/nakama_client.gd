extends Node

enum op_codes {MATCH_SETUP, MOVE, ABILITY}

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var online_match : NakamaRTAPI.Match

signal opponent_move(to_pos)
signal opponent_use_ability(instructions)
signal match_making_phase(phase)
signal match_connect_msg(msg)

#Future update:
#signal remote_move_input
#signal remote_ability_input

const STARTER_CHARACTER_ID := "starter_character"

var current_match_phase := "waiting_for_players"
var local_player_id := ""
var local_team_id := 0


func _ready():
	create_online_session()


func create_online_session() -> void:
	#LOCAL TARGET
	client = Nakama.create_client("temporary_key", "127.0.0.1", 7350, "http")
	
	#AWS TARGET
	#client = Nakama.create_client("temporary_key", "tactical-chess.xyz", 443, "https")
	client.timeout = 10
	
	var device_id = OS.get_unique_id()
	session = await client.authenticate_device_async(device_id)
	# session receives an Object with: created, token, create_time, expire_time, expired, vars, username, user_id, refresh_token, refresh_expire_time, valid, exception
	
	if session.is_exception():
		push_error("An error occurred attempting to create Nakama Session:/n %s" % session)
		return 
	
	create_socket_connection()


func create_socket_connection() -> void:
	socket = Nakama.create_socket_from(client)
	
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	
	if connected.is_exception():
		print("An error occurred while attempting to open ws connection:/n %s" % connected)
		return
	
	socket.received_match_state.connect(handle_remote_input)
	socket.received_matchmaker_matched.connect(_on_matchmaker_matched)


func join_matchmaking_queue() -> void:
	var query = "*" #postgres matching query?
	var min_players : int = 2
	var max_players : int = 2
	#var string_properties = { "mode": "sabotage" }
	#var numeric_properties = { "skill": 125 }
	
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = await socket.add_matchmaker_async(query, min_players, max_players)
	
	if matchmaker_ticket.is_exception():
		print("error getting ticket from socket.add_matchmaker_async")
		return


func _on_matchmaker_matched(p_matched : NakamaRTAPI.MatchmakerMatched):
	#opponent found, agreeing on teams
	
	#p_matched props: match_id, ticket, token, users[], self
	#users[n]<MatchmakerUser> props: presence, numeric_properties, string_properties
	#presence<UserPresence> props: persistence, session_id, status, username, user_id
	
	var new_match : NakamaRTAPI.Match = await socket.join_matched_async(p_matched)
	
	if new_match.is_exception():
		print("MATCH FAILED TO CONNECT")
	else:
		print("MATCH CONNECTED")
		
		online_match = new_match
		match_making_phase.emit(current_match_phase)
		match_connect_msg.emit({
			"description": "_on_matchmaker_matched function triggered. p_matched object received and sent through socket.join_matched_async.",
			"p_matched": p_matched,
			"new_match": new_match,
		})


func _send_local_input_to_remote(input, op_code) -> void:
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = var_to_str(input.vectors[key])
	
	var state = JSON.stringify({
		"origin": Data.multiplayer_id,
		"input": input
	})
	
	await socket.send_match_state_async(online_match.match_id, op_code, state)


func handle_remote_input(match_state: NakamaRTAPI.MatchData) -> void:
	var payload = JSON.parse_string(match_state.data)
	if typeof(payload) != TYPE_DICTIONARY:
		push_warning("Received unreadable match data.")
		return

	match int(match_state.op_code):
		
		Opcodes.CLIENT_ATTEMPT_MOVE:
			_receive_temporary_move(payload)
		
		Opcodes.CLIENT_ATTEMPT_USE_ABILITY:
			_receive_temporary_ability(payload)
		
		Opcodes.SERVER_MATCH_PHASE_CHANGED:
			_update_match_phase(payload)
		
		Opcodes.SERVER_MATCH_SETUP:
			await _handle_match_setup(payload)
		
		_:
			pass


func _update_match_phase(payload: Dictionary) -> void:
	var phase := str(payload.get("phase", ""))
	current_match_phase = phase
	match_making_phase.emit(current_match_phase)
	match_connect_msg.emit({"payload": payload})
	
	match phase:
		"validating_loadouts":
			await _send_player_setup()
		
		"preparing_setup":
			pass
		
		"running":
			SceneManager.start_online_match()


func _handle_match_setup(payload: Dictionary) -> void:

	var received_local_player_id := str(
		payload.get("local_player_id", "")
	)
	var received_local_team_id := int(
		payload.get("local_team_id", 0)
	)
	var received_players = payload.get("players", [])

	if received_local_player_id.is_empty():
		push_error("local_player_id is missing from _handle_match_setup payload.")
		return
	if received_local_team_id not in [Data.CGs.TEAM_1, Data.CGs.TEAM_2]:
		push_error("received_local_team_id is missing from _handle_match_setup payload, or an invalid team number was assigned.\n Expected %s or %s. Received: %s." % [Data.CGs.TEAM_1, Data.CGs.TEAM_2, received_local_team_id])
		return
	if typeof(received_players) != TYPE_ARRAY:
		push_error("Wrong variable type received by _handle_match_setup, for received_players. Expected an array, but received %s." % typeof(received_players))
		return
	if received_players.size() != 2:
		push_error("Expected 2 players in _handle_match_setup, but received an array of size %s in received_players." % received_players.size())
		return

	local_player_id = received_local_player_id
	local_team_id = received_local_team_id
	Data.multiplayer_id = local_player_id
	Data.player_control_group = local_team_id
	_build_character_list(received_players)
	await _send_setup_received()


func _build_character_list(match_players: Array) -> void:
	var characters: Array = []

	for player in match_players:
		var is_local := str(player.player_id) == local_player_id
		var team_id := int(player.team_id)
		var character_id := str(player.character_id)

		if character_id != STARTER_CHARACTER_ID:
			return

		characters.append({
			"player_id": str(player.player_id),
			"character_id": character_id,
			#TODO: remove model and process character_id in the character factory
			"model": "res://entities/test-character/player_character.tscn",
			"role": (
				Data.roles.PLAYER_CHARACTER
				if is_local
				else Data.roles.OPPOSING_PLAYER
			),
			"coords": (
				Vector2i(1, 1)
				if is_local
				else Vector2i(4, 1)
			),
			"control_group": team_id,
		})

	Data.match_settings.characters = characters


func _send_setup_received() -> void:
	await socket.send_match_state_async(
		online_match.match_id,
		Opcodes.CLIENT_SETUP_RECEIVED,
		JSON.stringify({})
	)


func _send_player_setup() -> void:
	var payload := {
		"character_id": STARTER_CHARACTER_ID,
	}

	await socket.send_match_state_async(
		online_match.match_id,
		Opcodes.CLIENT_PLAYER_SETUP,
		JSON.stringify(payload)
	)


func transmit_move_input(from_coords: Vector2i,	to_coords: Vector2i) -> void:
	var payload := {
		"vectors": {
			"from_coords": var_to_str(from_coords),
			"to_coords": var_to_str(to_coords),
		}
	}

	await socket.send_match_state_async(
		online_match.match_id,
		Opcodes.CLIENT_ATTEMPT_MOVE,
		JSON.stringify(payload)
	)


func _receive_temporary_move(payload: Dictionary) -> void:
	var vectors = payload.get("vectors", {})
	if typeof(vectors) != TYPE_DICTIONARY:
		return

	var to_coords = str_to_var(
		str(vectors.get("to_coords", ""))
	)
	if typeof(to_coords) != TYPE_VECTOR2I:
		return

	# Preserve the current viewer-relative mirroring.
	to_coords.x = 5 - to_coords.x
	opponent_move.emit(to_coords)


func transmit_ability_input(instructions: Dictionary) -> void:
	var outgoing := instructions.duplicate(true)

	if outgoing.has("vectors"):
		for key in outgoing.vectors:
			outgoing.vectors[key] = var_to_str(
				outgoing.vectors[key]
			)

	await socket.send_match_state_async(
		online_match.match_id,
		Opcodes.CLIENT_ATTEMPT_USE_ABILITY,
		JSON.stringify(outgoing)
	)


func _receive_temporary_ability(payload: Dictionary) -> void:
	var instructions := payload.duplicate(true)

	if instructions.has("vectors"):
		for key in instructions.vectors:
			var vector_value = str_to_var(
				str(instructions.vectors[key])
			)
			if vector_value == null:
				continue

			if key == "start_pos":
				vector_value.x = 6.6 - vector_value.x
			else:
				vector_value.x = 5 - vector_value.x

			instructions.vectors[key] = vector_value

	opponent_use_ability.emit(instructions)


func _old_handle_remote_input(match_state : NakamaRTAPI.MatchData):
	#print("Match data received remotely. match_state object contains: " + str(match_state))
	var data = JSON.parse_string(match_state.data)
	var input = data.input
	
	
	#Mirror Vector values
	#0,0 is upper left grid pos, 5,2 is lower right (from player perspective)
	#y positioning will not change. But x position is reversed.
	#all x-coord values from remote need to be converted to 5-x
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = str_to_var(input.vectors[key])
			if input.vectors[key] == null: continue
			if key == "start_pos":
				input.vectors[key].x = 6.6 - input.vectors[key].x
			else:
				input.vectors[key].x = 5 - input.vectors[key].x
	
	#TODO: Eliminate this flip and rely on caster directions in cast
	if input.has("travel_direction"): 
		push_error("Match input received with travel_direction property. Payload received: /n" + str(input))
	
	match match_state.op_code:
		op_codes.MATCH_SETUP:
			_old_handle_ready_step(input)
		op_codes.MOVE:
			opponent_move.emit(input.vectors.to_coords)
		op_codes.ABILITY:
			opponent_use_ability.emit(input)
		_:
			print("Unsupported op code.")


func _old_handle_ready_step(remote_input : Dictionary) -> void:
	#print("_handle_ready_step remote_input Dictionary: " + str(remote_input))
	match int(remote_input.ready_step):
		
		Data.matchmaking_steps.HANDSHAKE:
			Data.match_settings.handshake.opponent.coin_toss = remote_input.coin_toss
			Data.match_settings.handshake.opponent.ready = true
			if Data.ready_check("handshake"): _old_prepare_combat_data()
		
		Data.matchmaking_steps.COMBAT_DATA:
			var character_settings = {
				"model": remote_input.model,
				"role": Data.roles.OPPOSING_PLAYER,
				"coords": remote_input.vectors.home_coords,
				"control_group": int(remote_input.control_group),
			}
			Data.match_settings.characters.push_back(character_settings)
			Data.match_settings.combat_data.opponent.ready = true
			var matchmaker_update_data = {
				"character_settings": character_settings,
				"note": "Combat package received from remote remote."
			}
			if Data.ready_check("combat_data"): 
				matchmaker_update_data.combat_ready_result = true
				matchmaker_update.emit(Data.matchmaking_steps.COMBAT_DATA, matchmaker_update_data)
				SceneManager.start_online_match()
			else:
				matchmaker_update_data.combat_ready_result = false
				matchmaker_update.emit(Data.matchmaking_steps.COMBAT_DATA, matchmaker_update_data)
				push_warning("Combat ready check failed after receiving remote combat package.")
			
		_:
			push_warning("_handle_ready_step received an unknown or non-existent ready_step value.")


func _old_prepare_combat_data() -> void: 
	#character model, attributes, control_group, deck
	var handshake = Data.match_settings.handshake
	var player_wins_toss = handshake.player.coin_toss > handshake.opponent.coin_toss
	
	if player_wins_toss: Data.player_control_group = Data.CGs.TEAM_1
	else: Data.player_control_group = Data.CGs.TEAM_2
	Data.match_settings.characters[0].control_group = Data.player_control_group
	
	var combat_package = {
		"ready_step": Data.matchmaking_steps.COMBAT_DATA,
		"model": Data.match_settings.characters[0].model,
		"control_group": Data.player_control_group,
		"vectors": {
			"home_coords": Data.match_settings.characters[0].coords
		},
	}
	#bot_config
	#deck_config
	
	Data.match_settings.combat_data.player.ready = true
	_send_local_input_to_remote(combat_package, op_codes.MATCH_SETUP)
		
	if Data.ready_check("combat_data"): SceneManager.start_online_match()


func _old_transmit_move_input(from_coords: Vector2i, to_coords: Vector2i) -> void:
	var move_input = {
		"vectors":{
			"from_coords": from_coords,
			"to_coords": to_coords,
		}
	}
	
	_send_local_input_to_remote(move_input, op_codes.MOVE)


func _old_transmit_ability_input(instructions: Dictionary) -> void:
	_send_local_input_to_remote(instructions, op_codes.ABILITY)
