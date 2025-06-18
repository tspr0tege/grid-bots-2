class_name Shot extends Node3D

@export var dmg := 1.0
signal attempt_damage(grid_coords: Vector2i, amt: float)
var grid_coords: Vector2i
var shots_index: int

func _hit_character(target: Character):
	#emit_signal("attempt_damage", grid_coords, dmg)
	target.get_node("HpNode").take_damage(dmg)
	queue_free()
