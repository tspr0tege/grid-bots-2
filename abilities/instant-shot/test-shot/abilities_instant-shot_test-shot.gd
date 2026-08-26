extends Ability

@export var dmg := 10.0
@export var sound : SoundResource


func validate(caster_id : String) -> Dictionary:
	var caster = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions := {
		"can_cast": true,
		"ability_id": ability_id,
		"caster_id": caster_id,
		"vectors": {"target_coords": null},
	}

	#NOTE: to be handled by RESOLVER
	#var target = MatchSettings.BRIDGE.find_character_by_arena_row(caster.grid_coords, caster.attack_direction)
	#if target:
		#instructions.vectors.target_coords = target.grid_coords
	
	return instructions


func cast(instructions: Dictionary) -> void:
	var caster = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	
	caster.animate_action("shoot")
	SoundManager.play_audio_stream(sound)
	
	#if instructions.vectors.target_coords != null:
		#MatchSettings.BRIDGE.attempt_damage(instructions.vectors.target_coords, dmg)
	#TODO: defer damage decisions to RESOLVER
