extends Node3D

var grid_pos : Vector2i
@export var move_handler: MovementStyle

func move_to(new_pos) -> void:
	if move_handler:
		move_handler.move(self, new_pos)
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos,.1)
	
