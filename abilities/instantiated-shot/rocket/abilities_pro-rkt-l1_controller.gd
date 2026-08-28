extends ProjectileController

#var instantiated_projectile : Node3D
#var grid_coords : Vector2i

#Rocket needs to travel x amount by (current tick + ticks_to_next_tile)
#arrive_on_tick = tick_count + ticks_to_next_tile
#func travel_to_tile(target_coords: Vector2i, on_tick: int) -> void:
func _handle_move(instructions: Dictionary):
	print("_handle_move in rocket received:\t" + JSON.stringify(instructions))
	#instantiated_projectile.travel_to_tile(from_coords: Vector2i, to_coords: Vector2i, on_tick: int)
