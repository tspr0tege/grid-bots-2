extends Ability


func validate(caster: Character, arena: Node3D) -> Dictionary:
	var target = arena.enemy_character if caster == arena.player_character else arena.player_character
	instructions.ability_id = UID
	instructions.target_type = "OCCUPANT"
	instructions.vectors = {"target_coords": target.grid_pos}
	instructions.can_cast = true
	
	return instructions


func cast(_arena: Node3D, final_instructions: Dictionary) -> void:
	final_instructions.target.get_node("HpNode").affect_defense(-.25, 10)
	
