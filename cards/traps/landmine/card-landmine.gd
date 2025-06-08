extends Card

const LANDMINE = preload("res://cards/traps/landmine/landmine.tscn")


func play_card(caster : Character, arena : Node3D) -> void:
	var target_group: DataTypes.ControlGroups
	
	if caster.control_group == DataTypes.ControlGroups.BLUE:
		target_group = DataTypes.ControlGroups.RED
	else:
		target_group = DataTypes.ControlGroups.BLUE
	
	var possible_locations = arena.tiles_in_group(target_group)
	if possible_locations.size() < 1: return
	var target_tile = possible_locations[randi_range(0, possible_locations.size() - 1)]
	
	var new_mine = LANDMINE.instantiate()
	target_tile.add_child(new_mine)
	target_tile.traps.push_back(new_mine.trigger_trap)
	#add traps array to floor_tile scene
	#Possible: create class for traps with an execute func
