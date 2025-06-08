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
		$ResetTimer.connect("timeout", _set_control_group.bind(current_group))
		$ResetTimer.wait_time = reset_in
		$ResetTimer.start()
	
	control_group = group
	var tile_material = $MeshInstance3D.get_surface_override_material(0)
	match group:
		DataTypes.ControlGroups.BLUE:
			tile_material.albedo_color = Color(0, 0, .9)
		DataTypes.ControlGroups.RED:
			tile_material.albedo_color = Color(.9, .2, .2)


func add_occupant(new_occupant: Character) -> void:
	occupant = new_occupant
	for trap in traps:
		trap.call(new_occupant)
	traps = []


func remove_occupant() -> void:
	occupant = null
