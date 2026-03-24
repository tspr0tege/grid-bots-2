extends Ability

@export var summon_sound : SoundResource

const ROCK_CUBE = preload("res://abilities/summons/rock-cube/character_rock-cube.tscn")


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster: Character = amx.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": UID,
		#"control_group": caster.control_group
	}
	
	var target_tile = amx.get_arena_tile_by_coords(caster.grid_coords + Vector2i(caster.attack_direction, 0))
	
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


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var new_rock_cube_instructions = {
		"model": "res://abilities/summons/rock-cube/character_rock-cube.tscn",
		"role": Data.roles.NPCs,
		"coords": instructions.vectors.target_coords,
		#"control_group": instructions.control_group,
	}
	var new_rock_cube = amx.add_new_character(new_rock_cube_instructions)
	SoundManager.play_audio_stream(summon_sound)
	new_rock_cube.connect("character_death", amx.handle_character_death)
