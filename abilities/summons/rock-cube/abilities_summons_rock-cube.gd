extends Ability

@export var summon_sound : SoundResource

const ROCK_CUBE = preload("res://abilities/summons/rock-cube/character_rock-cube.tscn")


func validate(caster_id : String) -> Dictionary:
	var caster: Character = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": ability_id,
		#"team": caster.team
	}
	
	var target_tile = MatchSettings.BRIDGE.get_arena_tile_by_coords(caster.grid_coords + Vector2i(caster.attack_direction, 0))
	
	if target_tile == null: 
		instructions.can_cast = false
		instructions.reason = "No valid tile available in front of caster."
		return instructions
	
	if target_tile.occupant: #TODO: Replace this with damage behavior
		instructions.can_cast = false
		instructions.reason = "Target tile is occupied."
		return instructions
		
	instructions.can_cast = true
	instructions.vectors = {"target_coords": target_tile.grid_coordinates}
	
	return instructions


func cast(instructions: Dictionary) -> void:
	var new_rock_cube_instructions = {
		"model": "res://abilities/summons/rock-cube/character_rock-cube.tscn",
		"role": MatchSettings.roles.NPCs,
		"coords": instructions.vectors.target_coords,
		#"team": instructions.team,
	}
	var new_rock_cube = MatchSettings.BRIDGE.add_new_character(new_rock_cube_instructions)
	SoundManager.play_audio_stream(summon_sound)
	#new_rock_cube.connect("character_death", MatchSettings.BRIDGE.handle_character_death)
