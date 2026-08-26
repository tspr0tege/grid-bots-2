extends Ability

@export var sound : SoundResource

func validate(caster_id : String) -> Dictionary:
	#search in row for a tile that is NOT matching the character and switch it
	#var target = arena.linear_search(caster, "TILE")
	var caster = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": ability_id,
	}
	var opponent_cg = MatchSettings.opposing_team(caster.team)
	var target = MatchSettings.BRIDGE.find_arena_tile_in_row_by_team(caster.grid_coords, caster.attack_direction, opponent_cg)
	if target == null:
		instructions.can_cast = false
		instructions.reason = "No tile found, for conversion."
		return instructions
	
	instructions.can_cast = true
	instructions.vectors = {"target_coords": target.grid_coordinates}
	instructions.team = caster.team
	return instructions


func cast(instructions: Dictionary) -> void:
	var target_tile = MatchSettings.BRIDGE.get_arena_tile_by_coords(instructions.vectors.target_coords)
	SoundManager.play_audio_stream(sound)
	target_tile._set_team(instructions.team)
