class_name Trap3D extends Node3D

var grid_coordinates: Vector2i

func trigger_trap() -> void:
	#class contains reference to grid_coordinates
	print("Trap %s triggered without a custom trigger_trap function." % self.name)
