extends Ability

@export var dmg := 10.0


func validate(caster, arena) -> Dictionary:
	instructions.target_type = "OCCUPANT"
	instructions.can_cast = true
	instructions.ability_id = UID
	caster.animate_action("shoot")
	$AudioStreamPlayer.play()
	var target = arena.search_row(caster.grid_pos, caster.attack_direction, arena.for_character)
	if target:
		instructions.vectors = {"target_coords": target.grid_pos}
	else:
		instructions.vectors = {"target_coords": null}
	
	return instructions


func cast(arena, final_instructions) -> void:
	if final_instructions.target:
		arena._attempt_damage(final_instructions.vectors.target_coords, dmg)
