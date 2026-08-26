extends Ability

const ROCKET = preload("res://abilities/instantiated-shot/rocket/objects_rocket.tscn")


func cast(instructions: Dictionary) -> void:
	var caster = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	var new_rocket = ROCKET.instantiate()
	new_rocket.team = caster.team
	new_rocket.position = instructions.vectors.start_pos
	new_rocket.travel_direction = caster.attack_direction #handled by authority
	
	#new_rocket.connect("update_tile_position", MatchSettings.BRIDGE.bind_projectile_move(new_rocket)) #this will be handled by authority
	#MatchSettings.BRIDGE.connect_signal_to_arena(new_rocket, "attempt_damage", "_attempt_damage")
	#MatchSettings.BRIDGE.add_child_to_arena(new_rocket)
	#TODO: use ActorFactory spawn_projectile.
	#TODO: AbilityMethodsRegister for movement?
