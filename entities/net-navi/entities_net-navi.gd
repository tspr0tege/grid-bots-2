extends Character

@export var right_hand_anchor : Node3D

func move_to(new_pos: Vector3, pushed := false) -> void:
	if !pushed and move_handler:
		move_handler.move(self, new_pos)
		animate_action("move")
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos, tile_move_speed)
