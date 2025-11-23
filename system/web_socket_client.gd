extends Node

var tls_options: TLSOptions = null

var socket := WebSocketPeer.new()
var last_state := WebSocketPeer.STATE_CLOSED
var next_action : Dictionary = {}
#var remote_opponent_id = null

var ARENA : Node3D

signal connected_to_server()
signal connection_closed()
signal message_received(message: Variant)
#signal received_new_room_code(code)

signal opponent_move(to_pos)
#signal opponent_use_ability(ability_uid)


func connect_to_url(url: String) -> int:
	#socket.supported_protocols = supported_protocols
	#socket.handshake_headers = handshake_headers
	print("connecting to URL")

	var err := socket.connect_to_url(url, tls_options)
	if err != OK:
		print(err)
		return err

	last_state = socket.get_ready_state()
	return OK


func close(code: int = 1000, reason: String = "") -> void:
	socket.close(code, reason)
	last_state = socket.get_ready_state()


func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()

	var state := socket.get_ready_state()

	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			print("Connected to server")
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			print("Socket Closed")
			connection_closed.emit()
	
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		print("Message received")
		var received := socket.get_packet()
		var packet_from_utf8 = received.get_string_from_utf8()
		var data = JSON.parse_string(packet_from_utf8)
		print(data)
		message_received.emit(data)
		
		if Data.multiplayer_id == null and data.has("id"):
			Data.multiplayer_id = data.id
		
		if "error" in data:
			print("ERROR received from server: " + str(data.error))
		
		if !next_action.is_empty():
			print("Running next_action")
			#TODO: change next_action into a follow-up parkable function call
			if next_action.id == null: next_action.id = Data.multiplayer_id
			socket.put_packet(JSON.stringify(next_action).to_utf8_buffer())
			next_action.clear()
				
		if data.has("type"):
			match data.type:
				
				"new_offer":
					print("New offer created and room code received")
					SceneManager.emit_new_room_code(data.room_code)
					#data.room_code
					
				"new_opponent":
					print("Connected to new remote opponent")
					Data.opponent_id = data.opponent_id
					#SceneManager.connect_to_remote_opponent()
					SceneManager.start_online_match()
					
				"game_input":
					#print("Processing input from remote")
					handle_remote_input(data)
					
				"error":
					push_error(data.error_message)
					
				_:
					print("data dictionary has unknown type: " + str(data.type))


func _process(_delta: float) -> void:
	poll()


func handle_remote_input(input: Dictionary) -> void:
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = str_to_var(input.vectors[key])
			input.vectors[key].x = 5 - input.vectors[key].x
	
	if input.has("travel_direction"): input.travel_direction *= -1
	
	match input.action:
		"MOVE":
			#0,0 is upper left grid pos, 5,2 is lower right (from player perspective)
			#y positioning will not change. But x position is reversed.
			#all x-coord values from remote need to be converted to 5-x
			
			opponent_move.emit(input.vectors.to_coords)
		"ABILITY":
			ARENA._execute_ability(input)
		_:
			print("Remote input received, with no match statement to handle it.")


func send_local_input_to_remote(input) -> void:
	if input.has("vectors"):
		for key in input.vectors:
			input.vectors[key] = var_to_str(input.vectors[key])
	
	socket.send_text(JSON.stringify({
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": input
	}))


func generate_invite_code() -> void:
	print("Invite code request received in web_socket_client")
	var create_signal = {
		"id": Data.multiplayer_id,
		"type": "create_offer"
	}
	if socket.get_ready_state() != socket.STATE_OPEN:
		next_action = create_signal
		connect_to_url("ws://127.0.0.1:9080")
		#connect_to_url("wss://tactical-chess.xyz")
	else:
		socket.put_packet(JSON.stringify(create_signal).to_utf8_buffer())


func claim_invite_code(code) -> void:
	print("Join code being sent")
	var join_signal = {
		"id": Data.multiplayer_id,
		"type": "claim_offer",
		"room_code": code
	}
	if socket.get_ready_state() != socket.STATE_OPEN:
		next_action = join_signal
		connect_to_url("ws://127.0.0.1:9080")
		#connect_to_url("wss://tactical-chess.xyz")
	else:
		socket.put_packet(JSON.stringify(join_signal).to_utf8_buffer())
