extends ProjectileController

#var projectile_id : String
#var instantiated_projectile : Node3D
#var grid_coords : Vector2i
#var current_revision : int
var damage_amount := 20

#Rocket needs to travel x amount by (current tick + ticks_to_next_tile)
#arrive_on_tick = tick_count + ticks_to_next_tile
func _handle_move(instructions: Dictionary):
	#var tick_now = MatchSettings.BRIDGE.get_tick_count()
	if grid_coords:
		var previous_tile: FloorTile = MatchSettings.BRIDGE.get_arena_tile_by_coords(grid_coords)
		previous_tile.remove_projectile(self)
	
	if instructions.from_coords.x < 6:
		var current_tile: FloorTile = MatchSettings.BRIDGE.get_arena_tile_by_coords(instructions.from_coords)
		current_tile.add_projectile(self)
	
	print("_handle_move in rocket received:\t" + JSON.stringify(instructions))
	grid_coords = instructions.from_coords
	instantiated_projectile.travel_to_tile(
		instructions.from_coords, 
		instructions.to_coords, 
		instructions.move_speed
		)


func _handle_collision(collision_coords: Vector2i = grid_coords) -> void:
	print("_handle_collision triggered in Rocket")
	#TODO: explosions
	var floor_tile: FloorTile = MatchSettings.BRIDGE.get_arena_tile_by_coords(collision_coords)
	floor_tile.remove_projectile(self)
	instantiated_projectile.queue_free()
	MatchSettings.BRIDGE.free_projectile_controller(projectile_id)
