extends AbilityMethodsRegister

const ROCKET = preload("res://abilities/instantiated-shot/rocket/objects_rocket.tscn")


func request_instructions(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster: Character = amx.get_character_by_id(caster_id)
	return {
		"caster_id": caster_id,
		"ability_id": ABILITY_DATA.ability_id,
		#NOTE: server will have character coords in state. Vectors do not need to be transmitted.
		#"vectors": {
			#"caster_coords": caster.grid_coords
		#} 
	}
	#Client and server will have ability JSON, so that does not need to be transmitted, except as an error/cheat check
	

func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var caster = amx.get_character_by_id(instructions.caster_id)
	var new_rocket = ROCKET.instantiate()
	new_rocket.control_group = caster.control_group
	new_rocket.position = instructions.vectors.start_pos
	new_rocket.travel_direction = caster.attack_direction #handled by authority
	
	new_rocket.connect("update_tile_position", amx.bind_projectile_move(new_rocket)) #this will be handled by authority
	amx.connect_signal_to_arena(new_rocket, "attempt_damage", "_attempt_damage")
	amx.add_child_to_arena(new_rocket)
