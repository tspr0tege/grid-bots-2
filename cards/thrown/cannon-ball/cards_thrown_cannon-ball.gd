extends Node3D

signal arc_completed
signal hit_floor
var dmg := 50.0
var target_grid_tile = null
var character_damage_promximity := false


func _process(delta: float) -> void:
	if character_damage_promximity and target_grid_tile.occupant:
		target_grid_tile.occupant.get_node("HpNode").take_damage(dmg)
		queue_free()
	
	if $Path/PathFollow3D/MeshInstance3D.global_position.y <= 0:
		emit_signal("hit_floor")
		character_damage_promximity = false


func execute_fall() -> void:
	emit_signal("arc_completed")
	character_damage_promximity = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	var fall_position = position
	fall_position.y -= 3
	tween.tween_property(self, "position", fall_position, .5)
	get_tree().create_timer(1).timeout.connect(queue_free)
