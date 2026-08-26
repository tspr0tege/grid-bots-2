extends Ability

@export var dmg: float = 30.0

const CANNON = preload("res://abilities/instant-shot/cannon/object_cannon.tscn")
# x 0.1   y 0.33   z 0.2

func validate(caster_id : String) -> Dictionary:
	var caster = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": ability_id,
		"caster_id": caster_id,
		"vectors": {},
	}
	
	var target = MatchSettings.BRIDGE.find_character_by_arena_row(caster.grid_coords, caster.attack_direction)
	if target:
		instructions.vectors.target_coords = target.grid_coords
	else:
		instructions.vectors.target_coords = null
	
	instructions.can_cast = true
	
	return instructions


func cast(instructions: Dictionary) -> void:
	#TODO: Alter cannon to attach to caster's arm - change (remove?) animation
	var caster = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	
	var new_cannon = CANNON.instantiate()
	new_cannon.position = Vector3(0.1, 0.33, 0.2) * caster.attack_direction
	new_cannon.get_node("AnimationPlayer").play("shoot")
	new_cannon.get_node("Blast").connect("finished", new_cannon.queue_free)
	
	caster.add_child(new_cannon)
	
	if instructions.vectors.target_coords != null:
		MatchSettings.BRIDGE.attempt_damage(instructions.vectors.target_coords, dmg)
