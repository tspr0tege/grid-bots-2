extends Ability

@export var dmg: float = 30.0

const CANNON = preload("res://abilities/instant-shot/cannon/object_cannon.tscn")
# x 0.1   y 0.33   z 0.2

func validate(caster: Character, arena: Node3D) -> Dictionary:
	instructions.target_type = "OCCUPANT"
	instructions.ability_id = UID
	
	var new_cannon = CANNON.instantiate()
	new_cannon.position = Vector3(0.1, 0.33, 0.2)
	new_cannon.get_node("AnimationPlayer").play("shoot")
	new_cannon.get_node("Blast").connect("finished", new_cannon.queue_free)
	caster.add_child(new_cannon)
	
	var target = arena.search_row(caster.grid_pos, caster.attack_direction, arena.for_character)
	if target:
		instructions.target_coords = target.grid_pos
	else:
		instructions.target_coords = null
	instructions.can_cast = true
	
	return instructions


func cast(arena: Node3D, final_instructions: Dictionary) -> void:
	if final_instructions.target:
		arena._attempt_damage(final_instructions.target_coords, dmg)
