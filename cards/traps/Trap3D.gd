class_name Trap3D extends Node3D

var grid_coordinates: Vector2i

func trigger_trap(trigger_cause: Character) -> void:
	#class contains reference to grid_coordinates
	print("Trap triggered by %s without a custom trigger_trap function." % trigger_cause)
