extends Ability

const ROCKET = preload("res://abilities/instantiated-shot/rocket/objects_rocket.tscn")


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	var position_offset = Vector3(.5 * caster.attack_direction, 0.5, 0)
	var instructions = {
		"target_type": "NONE",
		"ability_id": UID,
		"can_cast" : true,
		"vectors": {
			"start_pos" : caster.global_position + position_offset,
		},
		#TODO: remove these details from instructions and reference caster_id in func cast, instead.
		"control_group" : caster.control_group,
		"travel_direction" : caster.attack_direction,
	}
	
	return instructions


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var new_rocket = ROCKET.instantiate()
	new_rocket.control_group = instructions.control_group
	new_rocket.position = instructions.vectors.start_pos
	new_rocket.travel_direction = instructions.travel_direction
	
	new_rocket.connect("update_tile_position", amx.bind_projectile_move(new_rocket))
	amx.connect_signal_to_arena(new_rocket, "attempt_damage", "_attempt_damage")
	amx.add_child_to_arena(new_rocket)
