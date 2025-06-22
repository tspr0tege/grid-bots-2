extends Ability

const ROCKET = preload("res://abilities/instantiated-shot/rocket/objects_rocket.tscn")


func use_ability(caster : Character, arena : Node3D) -> bool:
	var position_offset = Vector3(.5 * caster.attack_direction, 0.5, 0)
	var new_rocket = ROCKET.instantiate()
	new_rocket.control_group = caster.control_group
	new_rocket.position = caster.global_position + position_offset
	new_rocket.travel_direction = caster.attack_direction
	new_rocket.connect("update_tile_position", arena._attempt_move_shot.bind(new_rocket))
	new_rocket.connect("attempt_damage", arena._attempt_damage)
	arena.add_child(new_rocket)
	return true
