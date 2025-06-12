extends Node3D

signal attempt_damage(grid: Vector2i, dmg: float, on_success: Callable)

var grid_position: Vector2i = Vector2i.ZERO
var travel_direction: int
var speed: float = 4
var dmg: float = 20.0

func _process(delta: float) -> void:
	position.x += (travel_direction * speed) * delta
	var x_offset = .55 + (grid_position.x * .1)
	grid_position.x = ceil(position.x - x_offset)
	$Label3D.text = str(x_offset)
	if grid_position.x >= 6: queue_free()
	else: emit_signal("attempt_damage", grid_position, dmg, self.queue_free)
