extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("punch")

func _attempt_knockback() -> void:
	var caster = get_parent()
	var attacking_pos = caster.grid_position
	attacking_pos.x += caster.attack_direction

func _on_animation_finished(anim_name: StringName) -> void:
	queue_free()
