class_name AbilityMethodsBridge extends RefCounted

var MATCH_CONTROLLER : MatchController
var ARENA : Arena


func _init(new_arena: Node3D, new_match_controller: Node):
	ARENA = new_arena
	MATCH_CONTROLLER = new_match_controller

#get_character_by_id
#add_new_character (ActorFactory and place)
func get_character_by_id(character_id: String) -> Character:
	return MATCH_CONTROLLER.characters[character_id]


func get_projectile_by_id(projectile_id: String) -> ProjectileController:
	return MATCH_CONTROLLER.projectiles[projectile_id]


func get_arena_tile_by_coords(coords: Vector2i) -> FloorTile:
	return ARENA.get_tile_by_coords(coords)


func get_tick_count() -> int:
	return MATCH_CONTROLLER.tick_count


func mount_new_projectile(projectile: ProjectileController) -> void:
	MATCH_CONTROLLER.projectiles[projectile.projectile_id] = projectile
	var projectile_model = projectile.instantiated_projectile
	var target_tile = ARENA.get_tile_by_coords(projectile.grid_coords)
	ARENA.add_child(projectile_model)
	projectile_model.global_position = target_tile.global_position + Vector3(.55, 0, 0)


func load_tick_instructions(instructions_set: Array) -> void:
	var tick_now = MATCH_CONTROLLER.tick_count + 1
	print("tick_now value: " + str(tick_now))
	
	for instruction: TickInstruction in instructions_set:
		#var real_tick = instruction.kickoff_tick + tick_now
		#instruction.set("kickoff_tick", instruction.kickoff_tick + tick_now)
		#instruction.kickoff_tick = tick_now + instruction.kickoff_tick
		instruction.kickoff_tick += tick_now
		#var queue_size = MATCH_CONTROLLER.tick_queue_size
		var target_index = instruction.kickoff_tick % MATCH_CONTROLLER.tick_queue_size
		print("kickoff_tick value:" + str(instruction.kickoff_tick))
		MATCH_CONTROLLER.tick_process_queue[target_index].push_back(instruction)


func free_projectile_controller(controller_id: String) -> void:
	MATCH_CONTROLLER.projectiles.erase(controller_id)
