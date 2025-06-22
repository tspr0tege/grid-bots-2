class_name Projectile extends Node3D

signal update_tile_position(new_coords: Vector2i)
signal attempt_damage(coords: Vector2i, damage: float)

var grid_coords: Vector2i
var shots_index: int
@export var travel_direction: int = 1
@export var control_group: Data.CGs = Data.CGs.NONE
@export var move_speed: float = 4
@export var dmg: float = 1.0


func _process(delta: float) -> void:
	_movement_behavior(delta)
	var new_grid_coords = Vector2i(floor(position.x / 1.1), floor(position.z / 1.1))
	if grid_coords != new_grid_coords:
		emit_signal("update_tile_position", grid_coords, new_grid_coords)


func _movement_behavior(delta: float) -> void:
	position.x += (travel_direction * move_speed) * delta


func _hit_character() -> void:
	emit_signal("attempt_damage", grid_coords, dmg)
	queue_free()


func exit_arena() -> void:
	queue_free()
