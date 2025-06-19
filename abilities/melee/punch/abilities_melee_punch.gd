extends Ability

const PUNCH = preload("res://abilities/melee/punch/object_punch.tscn")
var PUSH = load("res://abilities/melee/push/abilities_melee_push.tscn").instantiate()

const dmg := 50.0

func use_ability(caster: Character, arena : Node3D) -> bool:
	var new_punch = PUNCH.instantiate()
	var target_pos = caster.grid_pos + Vector2i(caster.attack_direction, 0)
	
	new_punch.connect("attempt_damage", arena._attempt_damage.bind(target_pos, dmg))
	new_punch.connect("attempt_push", PUSH.use_ability.bind(caster, arena))
	caster.add_child(new_punch)
	new_punch.global_rotation = Vector3.ZERO
	return true
