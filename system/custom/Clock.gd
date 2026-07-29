class_name Clock extends Resource

@export var ping_id := 0
@export var latest_ping_avg : int
@export var estimated_server_clock_difference : int
@export var last_successful_ping_ticks_ms := 0

@export var ping_results := []


func is_clock_sync_ready(socket: NakamaSocket) -> bool:
	return (
		socket != null
		and socket.is_connected_to_host()
		and ping_results.size() >= 5
		and Time.get_ticks_msec()
			- last_successful_ping_ticks_ms
			<= 60_000
	)


func send_clock_ping(socket: NakamaSocket) -> Dictionary:
	ping_id += 1
	var current_ping_id := ping_id
	var client_send_time := int(Time.get_unix_time_from_system() * 1000.0)
	var rpc_result: NakamaAPI.ApiRpc = await socket.rpc_async(
		"gridbots_clock_ping",
		{
			"ping_id": current_ping_id,
			"client_ping_send_time": client_send_time,
		}
	)
	var client_pong_received_time := int(Time.get_unix_time_from_system() * 1000.0)

	if rpc_result.is_exception():
		push_warning("Clock ping failed: %s" % rpc_result.get_exception().message)
		return {}

	var response = JSON.parse_string(rpc_result.payload)

	if typeof(response) != TYPE_DICTIONARY:
		push_warning("Clock ping returned unreadable data.")
		return {}

	if int(response.get("ping_id", -1)) != ping_id:
		push_warning("Clock ping returned the wrong ping ID.")
		return {}
	
	return {
		"ping_id": int(response.ping_id),
		"client_ping_send_time": int(response.client_ping_send_time),
		"server_ping_received_time": int(response.server_ping_received_time),
		"server_pong_send_time": int(response.server_pong_send_time),
		"client_pong_received_time": client_pong_received_time,
		#NOTE: round trip MUST be calculated this way, due to possible clock offsets
		"round_trip_time": ( 
			(client_pong_received_time
			- int(response.client_ping_send_time))
			- (int(response.server_pong_send_time)
			- int(response.server_ping_received_time))
		),
	}


func _calculate_clock_offset(ping_result: Dictionary) -> int:
	#"ping_id", "client_ping_send_time", "server_ping_received_time", "server_pong_send_time", "client_pong_received_time", "round_trip_time"
	var server_clock_difference := int(
		ping_result.server_ping_received_time
		- ping_result.client_ping_send_time
		+ ping_result.server_pong_send_time
		- ping_result.client_pong_received_time
	) / 2
	
	return server_clock_difference


func _add_new_ping_result(ping_result: Dictionary) -> void:
	ping_results.push_front(ping_result)
	last_successful_ping_ticks_ms = Time.get_ticks_msec()
	
	while ping_results.size() > 5:
		ping_results.pop_back()


func test_ping(socket: NakamaSocket, count: int = 1, delay: float = 0.0) -> void:
	
	#TODO: control for missing single_ping results. Use a while loop, with some kind of guardrail against too many failures
	for n in range(count):
		var single_ping = await send_clock_ping(socket)
		
		if not single_ping.is_empty():
			_add_new_ping_result(single_ping)
		
		if delay > 0.0: 
			var tree: SceneTree = Engine.get_main_loop() as SceneTree
			await tree.create_timer(delay).timeout
	
	_update_clock_measures()


func _update_clock_measures() -> void:
	var sort_by_ping = func(a, b): return a.round_trip_time < b.round_trip_time
	var sorted_array = ping_results.duplicate()
	sorted_array.sort_custom(sort_by_ping)
	estimated_server_clock_difference = _calculate_clock_offset(sorted_array[0])
	
	latest_ping_avg = ping_results.reduce(func (acc, n): return acc + n.round_trip_time, 0) / ping_results.size()
