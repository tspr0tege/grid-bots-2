extends Area3D

@export var grid_coordinates : Vector2i
@export var control_group : DataTypes.ControlGroups
var occupant : Character
var traps := []
#state : tbd


func _set_control_group(group : DataTypes.ControlGroups, reset_in: float = 0.0) -> void:
	#print("Changing control group to " + str(group))
	if reset_in > 0:
		var current_group = control_group
		get_tree().create_timer(reset_in).timeout.connect(_set_control_group.bind(current_group))
	
	control_group = group
	var tile_material = $MeshInstance3D.get_surface_override_material(0)
	match group:
		DataTypes.ControlGroups.BLUE:
			tile_material.albedo_color = Color(0, 0, .9)
		DataTypes.ControlGroups.RED:
			tile_material.albedo_color = Color(.9, .2, .2)


func break_tile() -> void:
	$MeshInstance3D.visible = false
	_set_control_group(DataTypes.ControlGroups.NONE, 10.0)
	get_tree().create_timer(10).timeout.connect(repair_tile)


func repair_tile() -> void:
	$MeshInstance3D.visible = true


func add_occupant(new_occupant: Character) -> void:
	occupant = new_occupant
	for trap in traps:
		trap.call(new_occupant)
	traps = []


func remove_occupant() -> void:
	occupant = null
