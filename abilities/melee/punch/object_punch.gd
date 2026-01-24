extends Node3D

signal attempt_push
signal attempt_damage

func _ready() -> void:
	$AnimationPlayer.play("punch")


func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
