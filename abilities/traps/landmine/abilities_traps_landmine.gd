extends Ability

const LANDMINE = preload("res://abilities/traps/landmine/objects_landmine.tscn")


func use_ability(caster : Character, arena : Node3D) -> bool:
	var target_group: Data.CGs
	
	if caster.control_group == Data.CGs.BLUE:
		target_group = Data.CGs.RED
	else:
		target_group = Data.CGs.BLUE
	
	var possible_locations = arena.tiles_in_group(target_group)
	if possible_locations.size() < 1: return false
	var target_tile = possible_locations[randi_range(0, possible_locations.size() - 1)]
	
	var new_mine = LANDMINE.instantiate()
	target_tile.add_child(new_mine)
	target_tile.traps.push_back(new_mine.trigger_trap)
	#add traps array to floor_tile scene
	#Possible: create class for traps with an execute func
	return true
