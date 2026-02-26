extends Ability

@export var dmg: float = 30.0

const CANNON = preload("res://abilities/instant-shot/cannon/object_cannon.tscn")
# x 0.1   y 0.33   z 0.2

func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	var instructions := {
		"target_type": "OCCUPANT",
		"ability_id": UID,
		"caster_id": caster_id,
		"vectors": {
			#"caster_coords": caster.grid_pos
		}
	}
	
	var target = amx.find_character_by_arena_row(caster.grid_pos, caster.attack_direction)
	if target:
		instructions.vectors.target_coords = target.grid_pos
	else:
		instructions.vectors.target_coords = null
	
	instructions.can_cast = true
	
	return instructions


func cast(amx : AbilityMethodsExport, instructions: Dictionary) -> void:
	#var caster: Character = arena.get_tile_by_coords(instructions.vectors.caster_coords).occupant
	
	var new_cannon = CANNON.instantiate()
	new_cannon.position = Vector3(0.1, 0.33, 0.2) * instructions.caster.attack_direction
	#if caster.attack_direction == -1: new_cannon.rotation.y += deg_to_rad(180)
	new_cannon.get_node("AnimationPlayer").play("shoot")
	new_cannon.get_node("Blast").connect("finished", new_cannon.queue_free)
	instructions.caster.add_child(new_cannon)
	
	if instructions.target:
		amx.attempt_damage(instructions.vectors.target_coords, dmg)
