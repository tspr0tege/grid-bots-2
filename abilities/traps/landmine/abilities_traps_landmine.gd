extends Ability

const LANDMINE = preload("res://abilities/traps/landmine/objects_landmine.tscn")

@export var dmg: float = 25.0


func use_ability(caster : Character, arena : Node3D) -> bool:
	var target_group = Data.opposing_group(caster)
	var possible_locations: Array = arena.tiles_in_group(target_group)
	var all_clear = func(tile) -> bool:
		return tile.occupant == null and tile.traps.size() < 1
	
	possible_locations = possible_locations.filter(all_clear)
	if possible_locations.size() < 1: return false
	
	var target_tile = possible_locations[randi_range(0, possible_locations.size() - 1)]	
	var new_mine: Trap3D = LANDMINE.instantiate()
	new_mine.grid_coordinates = target_tile.grid_coordinates
	target_tile.add_child(new_mine)
	target_tile.traps.push_back(detonate_mine.bind(arena, new_mine))
	return true

func detonate_mine(arena, mine) -> void:
	mine.trigger_trap()
	arena._attempt_damage(mine.grid_coordinates, dmg)
