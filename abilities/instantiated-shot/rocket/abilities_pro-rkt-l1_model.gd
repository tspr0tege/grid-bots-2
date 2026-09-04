extends Node3D

const tile_size := 1.1
var destination_position : Vector3
#var arrival_tick : int
var lerp_strength : float
var move_speed : float


func _process(delta: float) -> void:
	#var delta_in_ms = int(delta * 1000)
	#var current_tick = MatchSettings.BRIDGE.get_tick_count()
	var direction = destination_position.x - self.global_position.x
	direction = direction / abs(direction)
	global_position.x += move_speed * direction * delta
	#var ticks_until_arrival = arrival_tick - current_tick
	#global_position.x += delta * move_speed
	#if ticks_until_arrival > 0:
		#var lerp_strength = 1.0 / ticks_until_arrival
		#global_position = lerp(global_position, destination_position, lerp_strength)


#Rocket needs to travel x amount by (current tick + ticks_to_next_tile)
#arrive_on_tick = tick_count + ticks_to_next_tile
func travel_to_tile(from_coords: Vector2i, to_coords: Vector2i, ticks_per_tile: int) -> void:
	var tick_now = MatchSettings.BRIDGE.get_tick_count()
	var travel_direction = to_coords - from_coords
	destination_position.z = (to_coords.y * tile_size) + .55
	var seconds_per_tile = float(ticks_per_tile) / 40.0
	move_speed = tile_size / seconds_per_tile
	#move_speed = (on_tick - tick_now) / 40.0 #seconds to clear one tile
	#arrival_tick = on_tick
	if travel_direction.x > 0: #traveling right - destination is left edge
		#global_position.x = from_coords.x * 1.1
		destination_position.x = to_coords.x * 1.1
	else:  #traveling left - destination is right edge
		#global_position.x = (from_coords.x + 1) * 1.1
		destination_position.x = (to_coords.x + 1) * 1.1 
		#move_speed *= -1
		
	print("Processing travel to tile instructions on tick: %s\t from_coords: %s,\t to_coords: %s,\t move_speed: %s" % [tick_now, from_coords, to_coords, ticks_per_tile])
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.tween_property(self, "global_position", destination_position, 0.5)
	#lerp_strength = 1.0 / float(on_tick - tick_now)
