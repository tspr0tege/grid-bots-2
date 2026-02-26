extends Ability

@export var dmg := 10.0


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	var instructions := {
		"target_type": "OCCUPANT",
		"can_cast": true,
		"ability_id": UID,
		"caster_id": caster_id,
		"vectors": {
			#"caster_coords": caster.grid_pos
		},
	}
	
	var target = amx.find_character_by_arena_row(caster.grid_pos, caster.attack_direction)
	if target:
		instructions.vectors.target_coords = target.grid_pos
	else:
		instructions.vectors.target_coords = null
	
	return instructions


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	#var caster: Character = arena.get_tile_by_coords(final_instructions.vectors.caster_coords).occupant
	
	instructions.caster.animate_action("shoot")
	$AudioStreamPlayer.play()
	
	if instructions.target:
		amx.attempt_damage(instructions.vectors.target_coords, dmg)
