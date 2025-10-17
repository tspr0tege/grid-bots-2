extends Ability

const ROCKET = preload("res://abilities/instantiated-shot/rocket/objects_rocket.tscn")


func validate(caster, _arena) -> Dictionary:
	var position_offset = Vector3(.5 * caster.attack_direction, 0.5, 0)
	instructions.merge({
		"target_type": "NONE",
		"ability_id": UID,
		"can_cast" : true,
		"starting_pos" : caster.global_position + position_offset,
		"control_group" : caster.control_group,
		"travel_direction" : caster.attack_direction,
	}, true)
	
	return instructions


func cast(arena, final_instructions) -> void:
	var new_rocket = ROCKET.instantiate()
	new_rocket.control_group = final_instructions.control_group
	new_rocket.position = final_instructions.starting_pos
	new_rocket.travel_direction = final_instructions.travel_direction
	new_rocket.connect("update_tile_position", arena._attempt_move_shot.bind(new_rocket))
	new_rocket.connect("attempt_damage", arena._attempt_damage)
	arena.add_child(new_rocket)
