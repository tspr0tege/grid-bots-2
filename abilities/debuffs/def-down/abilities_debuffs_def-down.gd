extends Ability


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	#var target = arena.enemy_character if caster == arena.player_character else arena.player_character
	var instructions := {
		"ability_id": UID,
		"target_type": "GROUP",
		"can_cast": true,
		"target": Data.opposing_group(caster.control_group),
	} 
	#instructions.vectors = {"target_coords": target.grid_pos}
	
	return instructions


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var target_ids = amx.get_all_on_team(instructions.target)
	for id in target_ids:
		var target = amx.get_character_by_id(id)
		target.get_node("HpNode").affect_defense(-.25, 10)
	#instructions.target.get_node("HpNode").affect_defense(-.25, 10)
	
