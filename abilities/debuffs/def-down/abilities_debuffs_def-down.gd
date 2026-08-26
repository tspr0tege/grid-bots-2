extends Ability


func validate(caster_id : String) -> Dictionary:
	var caster = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": ability_id,
		"can_cast": true,
		"target": MatchSettings.opposing_team(caster.team),
	} 
	
	return instructions


func cast(instructions: Dictionary) -> void:
	var target_ids = MatchSettings.BRIDGE.get_all_on_team(instructions.target)
	for id in target_ids:
		var target = MatchSettings.BRIDGE.get_character_by_id(id)
		target.get_node("HpNode").affect_defense(-.25, 10)
