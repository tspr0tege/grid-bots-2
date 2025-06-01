extends Card

const PUNCH = preload("res://cards/melee/punch/punch.tscn")

func play_card(caster: Character, arena : Node3D) -> void:
	print("Attempting punch")
	var new_punch = PUNCH.instantiate()
	new_punch.connect("attempt_push", arena._attempt_push)
	caster.add_child(new_punch)
	new_punch.global_rotation = Vector3.ZERO
