extends Node3D

const tile_width := 1.1
var destination_position : Vector3
var arrival_tick : int


func _process(_delta: float) -> void:
	#var delta_in_ms = int(delta * 1000)
	var current_tick = MatchSettings.BRIDGE.get_tick_count()
	var ticks_until_arrival = arrival_tick - current_tick
	var lerp_strength = 1 / ticks_until_arrival
	
	global_position = lerp(global_position, destination_position, lerp_strength)


#Rocket needs to travel x amount by (current tick + ticks_to_next_tile)
#arrive_on_tick = tick_count + ticks_to_next_tile
func travel_to_tile(from_coords: Vector2i, to_coords: Vector2i, on_tick: int) -> void:
	var travel_direction = to_coords - from_coords
	destination_position.z = (to_coords.y * 1.1) + .55
	destination_position.x = (
		to_coords.x * 1.1 #traveling right - destination is left edge
		if travel_direction.x > 0 
		else (to_coords.x + 1) * 1.1 #traveling left - destination is right edge
	)
	
	arrival_tick = on_tick
