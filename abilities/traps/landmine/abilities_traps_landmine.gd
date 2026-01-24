extends Ability

const LANDMINE = preload("res://abilities/traps/landmine/objects_landmine.tscn")

@export var dmg: float = 25.0


func validate(caster, arena) -> Dictionary:	
	var target_group = Data.opposing_group(caster)
	var possible_locations: Array = arena.tiles_in_group(target_group)
	var all_clear = func(tile) -> bool:
		return tile.occupant == null and !tile.trap
	
	possible_locations = possible_locations.filter(all_clear)
	
	if possible_locations.size() < 1: 
		instructions.can_cast = false
		instructions.reason = "No valid tile found for Landmine"
		return instructions
	
	var target_tile = possible_locations[randi_range(0, possible_locations.size() - 1)]	
	instructions.vectors = {
		"target_coords": target_tile.grid_coordinates
	}
	instructions.can_cast = true
	instructions.ability_id = UID
	instructions.target_type = "TILE"
	return instructions


func cast(arena, final_instructions) -> void:
	var target_tile = final_instructions.target
	var new_mine: Trap3D = LANDMINE.instantiate()
	new_mine.grid_coordinates = target_tile.grid_coordinates
	target_tile.trap = new_mine
	target_tile.add_child(new_mine)
	target_tile.connect("occupant_added", detonate_mine.bind(arena, new_mine))
	#connect("trigger_mine", detonate_mine.bind(arena, new_mine))
	#target_tile.traps.push_back(detonate_mine.bind(arena, new_mine))


func detonate_mine(_occupant, arena, mine) -> void:
	mine.get_parent().disconnect("occupant_added", self.detonate_mine)
	mine.trigger_trap()
	arena._attempt_damage(mine.grid_coordinates, dmg)
