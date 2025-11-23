extends Node3D

@onready var animation_player: AnimationPlayer = $blockbench_export/AnimationPlayer
const available_animations = ["shoot", "move", "run", "idle"]

func animate_action(animation) -> void:
	if available_animations.has(animation):
		animation_player.play(animation)
	else:
		print("NetNavi does not have an animation named %s" % animation)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name != "idle":
		animation_player.play("idle")
