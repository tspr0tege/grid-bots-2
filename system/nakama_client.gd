extends Node

enum op_codes {MATCH_SETUP, MOVE, ABILITY}

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var online_match : NakamaRTAPI.Match

signal match_connected

signal opponent_move(to_pos)
signal opponent_use_ability(instructions)
#Future update:
#signal remote_move_input
#signal remote_ability_input


func _ready():
	create_online_session()


func create_online_session() -> void:
	#client = Nakama.create_client("temporary_key", "127.0.0.1", 7350, "http")
	client = Nakama.create_client("temporary_key", "tactical-chess.xyz", 443, "https")
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
	#p_matched props: match_id, ticket, token, users[], self
	#users[n]<MatchmakerUser> props: presence, numeric_properties, string_properties
	#presence<UserPresence> props: persistence, session_id, status, username, user_id
	
	var new_match : NakamaRTAPI.Match = await socket.join_matched_async(p_matched)
	
	if new_match.is_exception():
		print("MATCH FAILED TO CONNECT")
	else:
		print("MATCH CONNECTED")
		online_match = new_match
		
		var self_user := p_matched.self_user.presence
		Data.multiplayer_id = self_user.username
		
		match_connected.emit()
		
		var coin_toss = randf()
		Data.match_settings.handshake.player.coin_toss = coin_toss
		var handshake_package = {
			"ready_step": Data.matchmaking_steps.HANDSHAKE,
			"coin_toss": coin_toss,
		}
		
		Data.match_settings.handshake.player.ready = true
		_send_local_input_to_remote(handshake_package, op_codes.MATCH_SETUP)
		
		if Data.ready_check("handshake"): _prepare_combat_data()


func _prepare_combat_data() -> void: 
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


func transmit_move_input(from_coords: Vector2i, to_coords: Vector2i) -> void:
	var move_input = {
		"vectors":{
			"from_coords": from_coords,
			"to_coords": to_coords,
		}
	}
	
	_send_local_input_to_remote(move_input, op_codes.MOVE)


func transmit_ability_input(instructions: Dictionary) -> void:
	_send_local_input_to_remote(instructions, op_codes.ABILITY)


func _send_local_input_to_remote(input, op_code) -> void:
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = var_to_str(input.vectors[key])
	
	var state = JSON.stringify({
		"origin": Data.multiplayer_id,
		"input": input
	})
	
	await socket.send_match_state_async(online_match.match_id, op_code, state)


func handle_remote_input(match_state : NakamaRTAPI.MatchData):
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
			_handle_ready_step(input)
		op_codes.MOVE:
			opponent_move.emit(input.vectors.to_coords)
		op_codes.ABILITY:
			opponent_use_ability.emit(input)
		_:
			print("Unsupported op code.")


func _handle_ready_step(remote_input : Dictionary) -> void:
	#print("_handle_ready_step remote_input Dictionary: " + str(remote_input))
	match int(remote_input.ready_step):
		
		Data.matchmaking_steps.HANDSHAKE:
			Data.match_settings.handshake.opponent.coin_toss = remote_input.coin_toss
			Data.match_settings.handshake.opponent.ready = true
			if Data.ready_check("handshake"): _prepare_combat_data()
		
		Data.matchmaking_steps.COMBAT_DATA:
			var character_settings = {
				"model": remote_input.model,
				"role": Data.roles.OPPOSING_PLAYER,
				"coords": remote_input.vectors.home_coords,
				"control_group": int(remote_input.control_group),
			}
			Data.match_settings.characters.push_back(character_settings)
			Data.match_settings.combat_data.opponent.ready = true
			if Data.ready_check("combat_data"): SceneManager.start_online_match()
			
		_:
			push_warning("_handle_ready_step received an unknown or non-existent ready_step value.")
