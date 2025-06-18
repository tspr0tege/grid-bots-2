extends Area3D

@export var grid_coordinates : Vector2i
@export var control_group : Data.CGs
var occupant : Character
var traps := []
var shots := []
#state : tbd


func _set_control_group(group : Data.CGs, reset_in: float = 0.0) -> void:
	#print("Changing control group to " + str(group))
	if reset_in > 0:
		var current_group = control_group
		get_tree().create_timer(reset_in).timeout.connect(_set_control_group.bind(current_group))
	
	control_group = group
	var tile_material = $MeshInstance3D.get_surface_override_material(0)
	match group:
		Data.CGs.BLUE:
			tile_material.albedo_color = Color(0, 0, .9)
		Data.CGs.RED:
			tile_material.albedo_color = Color(.9, .2, .2)


func break_tile() -> void:
	$MeshInstance3D.visible = false
	_set_control_group(Data.CGs.NONE, 10.0)
	get_tree().create_timer(10).timeout.connect(repair_tile)


func repair_tile() -> void:
	$MeshInstance3D.visible = true


func add_occupant(new_occupant: Character) -> void:
	occupant = new_occupant
	for trap in traps:
		trap.call(new_occupant)
	traps = []
	
	for shot in shots:
		shot._hit_character(new_occupant)
	shots = []


func remove_occupant() -> void:
	occupant = null


func add_shot(shot):
	if occupant:
		shot._hit_character(occupant)
	else:
		shot.shots_index = shots.size()
		shot.grid_coords = grid_coordinates
		shots.push_back(shot)


func remove_shot(index):
	print("Removing shot at index: " + str(index))
	print("Shot name: " + str(shots[index].name))
	shots.pop_at(index)
