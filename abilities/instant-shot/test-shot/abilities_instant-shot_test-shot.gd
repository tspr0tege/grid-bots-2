extends Ability

@export var dmg := 10.0

func use_ability(caster : Character, arena : Node3D) -> bool:
	#coords: Vector2i, direction: int, search_for: Callable
	var target = arena.search_row(caster.grid_pos, caster.attack_direction, arena.for_character)
	if target:
		#grid_coords: Vector2i, amt: float, on_success: Callable = func():pass
		arena._attempt_damage(target.grid_pos, dmg)
	$AudioStreamPlayer.play()
	return true

#func _attempt_attack(character: Character) -> void:
	##execute attack animation
	#character.shoot()
	##print("Found a target at %s. Target name: %s" % [Vector2i(x, target_row), target_tile.occupant.name])
	#var target = linear_search(character, "CHARACTER")
	#if target != null:
		#target.get_node("HpNode").take_damage(10)
