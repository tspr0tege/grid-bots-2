extends Character

signal attempt_move(agent, to_coords)

func _on_timer_timeout() -> void:
	var random_grid_coords = Vector2i(randi_range(2, 5), randi_range(0, 2))
	emit_signal("attempt_move", self, random_grid_coords)
	
