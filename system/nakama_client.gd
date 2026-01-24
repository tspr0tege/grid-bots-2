extends Node

enum op_codes {MOVE, ABILITY}

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var online_match : NakamaRTAPI.Match

signal match_connected
signal opponent_move(to_pos)

var ARENA : Node3D

func _ready():
	client = await Nakama.create_client("temporary_key", "127.0.0.1", 7350, "http")
	client.timeout = 10
	create_online_session()


func create_online_session() -> void:
	var device_id = OS.get_unique_id()
	session = await client.authenticate_device_async(device_id)
	# session receives an Object with: created, token, create_time, expire_time, expired, vars, username, user_id, refresh_token, refresh_expire_time, valid, exception
	
	if session.is_exception():
		print("An error occurred: %s" % session)
		return
	
	print("Successfully authenticated: %s" % session)
	print("Proceeding to open socket connection.")
	
	create_socket_connection()


func create_socket_connection() -> void:
	socket = Nakama.create_socket_from(client)
	
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	
	socket.received_match_state.connect(handle_remote_input)
	print("Socket connected. Moving to matchmaking queue")
	
	join_matchmaking_queue()


func join_matchmaking_queue() -> void:
	var query = "*" #postgres matching query?
	var min_players : int = 2
	var max_players : int = 2
	var string_properties = { "mode": "sabotage" }
	var numeric_properties = { "skill": 125 }
	
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = await socket.add_matchmaker_async(query, min_players, max_players)
	
	if matchmaker_ticket.is_exception():
		print("error getting ticket from socket.add_matchmaker_async")
		return
	
	print("Matchmaker successfully connected, attempting to join match.")
	socket.received_matchmaker_matched.connect(_on_matchmaker_matched)


func _on_matchmaker_matched(p_matched : NakamaRTAPI.MatchmakerMatched):
	#p_matched props: match_id, ticket, token, users[], self
	#users[n] props: <MatchmakerUser>: presence, numeric_properties, string_properties
	#presence props: <UserPresence>: persistence, session_id, status, username, user_id
	print("System triggered _on_matchmaker_matched")
	
	var new_match : NakamaRTAPI.Match = await socket.join_matched_async(p_matched)
	
	if new_match.is_exception():
		print("Match failed to connect.")
	else:
		print("Match connected")
		#print("new_match data: " + str(new_match))
		online_match = new_match
		match_connected.emit()


func send_local_input_to_remote(input) -> void:
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = var_to_str(input.vectors[key])
	
	var state = JSON.stringify({
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": input
	})
	var op_code = op_codes.MOVE if input.action == "MOVE" else op_codes.ABILITY
	
	await socket.send_match_state_async(online_match.match_id, op_code, state)


func handle_remote_input(match_state : NakamaRTAPI.MatchData):
	print("Match data received remotely. match_state object contains: " + str(match_state))
	var data = JSON.parse_string(match_state.data)
	var input = data.input
	
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = str_to_var(input.vectors[key])
			if input.vectors[key] == null: continue
			input.vectors[key].x = 5 - input.vectors[key].x
	
	if input.has("travel_direction"): input.travel_direction *= -1
	print("input: " + str(input))
	match match_state.op_code:
		op_codes.MOVE:
			#0,0 is upper left grid pos, 5,2 is lower right (from player perspective)
			#y positioning will not change. But x position is reversed.
			#all x-coord values from remote need to be converted to 5-x
			opponent_move.emit(input.vectors.to_coords)
		op_codes.ABILITY:
			if input.has("control_group"):
				input.control_group = Data.CGs.RED if input.control_group == Data.CGs.BLUE else Data.CGs.BLUE
			ARENA._execute_ability(input)
		_:
			print("Unsupported op code.")
