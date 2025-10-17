extends Node3D

signal attempt_push
signal attempt_damage

func _ready() -> void:
	$AnimationPlayer.play("punch")


func execute_hit() -> void:
	attempt_damage.emit()
	attempt_push.emit()


func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
