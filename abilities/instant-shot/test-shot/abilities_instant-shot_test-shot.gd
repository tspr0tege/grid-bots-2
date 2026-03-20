extends Ability

@export var dmg := 10.0
@export var sound : SoundResource


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	var instructions := {
		"target_type": "OCCUPANT",
		"can_cast": true,
		"ability_id": UID,
		"caster_id": caster_id,
		"vectors": {"target_coords": null},
	}
	
	var target = amx.find_character_by_arena_row(caster.grid_pos, caster.attack_direction)
	if target:
		instructions.vectors.target_coords = target.grid_pos
	
	return instructions


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var caster = amx.get_character_by_id(instructions.caster_id)
	
	caster.animate_action("shoot")
	SoundManager.play_audio_stream(sound)
	
	if instructions.vectors.target_coords != null:
		amx.attempt_damage(instructions.vectors.target_coords, dmg)
