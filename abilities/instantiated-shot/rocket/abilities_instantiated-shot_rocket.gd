extends Ability

const ROCKET = preload("res://abilities/instantiated-shot/rocket/objects_rocket.tscn")


func use_ability(caster : Character, arena : Node3D) -> bool:
	var new_rocket = ROCKET.instantiate()
	new_rocket.grid_position = caster.grid_pos
	new_rocket.grid_position.x += caster.attack_direction
	var starting_tile = arena.arena_tiles[new_rocket.grid_position.y][new_rocket.grid_position.x]
	new_rocket.position = starting_tile.global_position - Vector3(.5 * caster.attack_direction, 0 , 0)
	new_rocket.travel_direction = caster.attack_direction
	new_rocket.connect("attempt_damage", arena._attempt_damage)
	arena.add_child(new_rocket)
	return true
