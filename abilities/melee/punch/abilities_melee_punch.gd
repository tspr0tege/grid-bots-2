extends Ability

const PUNCH = preload("res://abilities/melee/punch/object_punch.tscn")
var PUSH = load("res://abilities/melee/push/abilities_melee_push.tscn")

const dmg := 50.0


func validate(caster_id : String) -> Dictionary:
	var caster = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var target_coords = caster.grid_coords + Vector2i(caster.attack_direction, 0)
	var instructions := {
		"caster_id": caster_id,
		"ability_id": ability_id,
		"can_cast": true,
		"vectors": {
			"target_coords": target_coords,
		},
	}
	
	return instructions


func cast(instructions: Dictionary) -> void:
	var caster = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	var target_coords = instructions.vectors.target_coords
	var new_punch = PUNCH.instantiate()
	
	new_punch.connect("attempt_damage", MatchSettings.BRIDGE.attempt_damage.bind(target_coords, dmg))
	new_punch.connect("attempt_push", MatchSettings.BRIDGE.attempt_ability.bind(caster, PUSH))
	caster.right_hand_anchor.add_child(new_punch)
	caster.animate_action("punch")
	new_punch.global_rotation = Vector3.ZERO
