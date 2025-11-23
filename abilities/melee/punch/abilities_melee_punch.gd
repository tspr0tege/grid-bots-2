extends Ability

const PUNCH = preload("res://abilities/melee/punch/object_punch.tscn")
var PUSH = load("res://abilities/melee/push/abilities_melee_push.tscn").instantiate()

const dmg := 50.0


func validate(caster, _arena) -> Dictionary:
	instructions.target_type = "OCCUPANT"
	instructions.target_coords = caster.grid_pos
	instructions.ability_id = UID
	instructions.can_cast = true
	
	instructions.target_pos = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	#var position_offset = Vector3(.5 * caster.attack_direction, 0.5, 0)
	
	return instructions


func cast(arena, final_instructions) -> void:
	var new_punch = PUNCH.instantiate()
	var target_pos = final_instructions.target_pos
	var caster = final_instructions.target
	
	new_punch.connect("attempt_damage", arena._attempt_damage.bind(target_pos, dmg))
	new_punch.connect("attempt_push", arena._attempt_ability.bind(caster, PUSH))
	caster.right_hand_anchor.add_child(new_punch)
	caster.animate_action("punch")
	new_punch.global_rotation = Vector3.ZERO
