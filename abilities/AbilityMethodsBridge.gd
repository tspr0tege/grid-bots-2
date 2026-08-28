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

func get_tick_count() -> int:
	return MATCH_CONTROLLER.tick_count


func mount_new_projectile(projectile: ProjectileController) -> void:
	MATCH_CONTROLLER.projectiles[projectile.projectile_id] = projectile
	var projectile_model = projectile.instantiated_projectile
	var target_tile = ARENA.get_tile_by_coords(projectile.grid_coords)
	projectile_model.global_position = target_tile.global_position
	ARENA.add_child(projectile_model)
