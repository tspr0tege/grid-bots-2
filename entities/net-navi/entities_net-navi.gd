extends Character


func move_to(new_pos: Vector3, pushed := false) -> void:
	if !pushed and move_handler:
		move_handler.move(self, new_pos)
		$NetNavi.animate_action("move")
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos, tile_move_speed)


func use_base_attack(arena: Node3D) -> void:
	if base_attack:
		base_attack.use_ability(self, arena)
		$NetNavi.animate_action("shoot")
	else:
		push_error("%s's use_base_attack function was called, with no BASE_ATTACK Script assigned." % self.name)
