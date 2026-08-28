class_name ProjectileController extends RefCounted

#var projectile_model : PackedScene
var projectile_id : String
var instantiated_projectile : Node3D
var grid_coords : Vector2i


func _init(projectile: Node3D) -> void:
	instantiated_projectile = projectile


#instructions: TickInstruction
func handle_tick_action(action_type: String, action_instructions: Dictionary) -> void:
	
	match action_type:
		"move":
			_handle_move(action_instructions)
		_:
			push_warning("ProjectileController received unknown action_type.\n action_type:\t %s\n action_instructions:\t %s\n" % [action_type, action_instructions])


func _handle_move(instructions: Dictionary) -> void:
	push_error("_handle_move function has been set for the ProjectileController on " + str(self.name))
