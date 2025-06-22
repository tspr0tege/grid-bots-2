extends Projectile

signal arc_completed
signal hit_floor
var live := false


func _process(_delta: float) -> void:
	if live and $Path/PathFollow3D/MeshInstance3D.global_position.y <= 0:
		emit_signal("hit_floor")
		live = false


func execute_fall() -> void:
	emit_signal("arc_completed")
	live = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", position + Vector3(0, -3, 0), .5)
	get_tree().create_timer(1).timeout.connect(queue_free)
