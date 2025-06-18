extends Ability

const PUNCH = preload("res://abilities/melee/punch/object_punch.tscn")

func use_ability(caster: Character, arena : Node3D) -> bool:
	var new_punch = PUNCH.instantiate()
	new_punch.connect("attempt_push", arena._attempt_push)
	caster.add_child(new_punch)
	new_punch.global_rotation = Vector3.ZERO
	return true
