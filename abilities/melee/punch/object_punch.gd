extends Node3D

signal attempt_push(pos, dir, dmg)


func _ready() -> void:
	$AnimationPlayer.play("punch")


func _attempt_push() -> void:
	var caster = get_parent()
	var attacking_pos = caster.grid_pos
	attacking_pos.x += caster.attack_direction
	emit_signal("attempt_push", attacking_pos, Vector2i(caster.attack_direction, 0), 50.0)


func _on_animation_finished(anim_name: StringName) -> void:
	queue_free()
