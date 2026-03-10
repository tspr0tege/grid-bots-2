extends Node3D

#signals are emitted from animation player
@warning_ignore("unused_signal")
signal attempt_push
@warning_ignore("unused_signal")
signal attempt_damage

func _ready() -> void:
	$AnimationPlayer.play("punch")


func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
