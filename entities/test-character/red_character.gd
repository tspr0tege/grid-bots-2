extends Character

signal attempt_move(character, to_coords)
signal search_for_target(source, target)

@export var attacking : bool = true


func _on_timer_timeout() -> void:
	if attacking:
		search_for_target.emit(self, "PLAYER_IN_ROW")
	else:
		target_result(false)


func target_result(found: bool) -> void:
	if found:
		use_base_attack()
	else:
		var random_grid_coords = Vector2i(randi_range(2, 5), randi_range(0, 2))
		emit_signal("attempt_move", self.character_id, random_grid_coords)
