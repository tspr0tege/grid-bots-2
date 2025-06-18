extends Ability


func use_ability(caster : Character, arena : Node3D) -> bool:
	print("Attempting to capture tile")
	#search in row for a tile that is NOT matching the character and switch it
	var target = arena.linear_search(caster, "TILE")
	if target != null:
		target._set_control_group(caster.control_group)
		return true
	else:
		return false
