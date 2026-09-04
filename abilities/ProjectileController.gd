class_name ProjectileController extends RefCounted

var projectile_id : String
var instantiated_projectile : Node3D
var grid_coords : Vector2i
var current_revision : int


func _init(projectile: Node3D) -> void:
	instantiated_projectile = projectile


#instructions: TickInstruction
func handle_tick_action(action_type: String, action_instructions: Dictionary) -> void:
	
	match action_type:
		"move":
			_handle_move(action_instructions)
		"fizzle":
			_handle_fizzle()
		"collision":
			_handle_collision()
		_:
			push_warning("ProjectileController received unknown action_type.\n action_type:\t %s\n action_instructions:\t %s\n" % [action_type, action_instructions])


func _handle_move(_instructions: Dictionary) -> void:
	push_error("_handle_move function has not been set for the ProjectileController on " + str(projectile_id))


func _handle_fizzle() -> void:
	print("Generic fizzle running on ProjectileController for " + str(projectile_id))
	instantiated_projectile.queue_free()
	MatchSettings.BRIDGE.free_projectile_controller(projectile_id)


func _handle_collision(_collision_coords: Vector2i = grid_coords) -> void:
	push_error("_handle_collision function has not been set for the ProjectileController on " + str(projectile_id))
