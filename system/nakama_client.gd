extends Node

var client : NakamaClient
var socket : NakamaSocket

func _ready():
	client = await Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	socket = Nakama.create_socket_from(client)
	
	var device_id = OS.get_unique_id()
	var session : NakamaSession = await client.authenticate_device_async(device_id)
	
	if session.is_exception():
		print("An error occurred: %s" % session)
		return
	print("Successfully authenticated: %s" % session)
	
	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")
