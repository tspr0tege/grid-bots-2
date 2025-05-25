extends Character

signal attempt_move(character, to_coords)
signal attempt_attack(character, action)


func _on_timer_timeout() -> void:
	if %CombatArena.player_character.grid_pos.y == self.grid_pos.y:
		emit_signal("attempt_attack", self)
	else:
		var random_grid_coords = Vector2i(randi_range(2, 5), randi_range(0, 2))
		emit_signal("attempt_move", self, random_grid_coords)
