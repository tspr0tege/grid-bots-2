extends Node3D

class_name Character

var grid_pos : Vector2i
@export var control_group := "NONE"
@export var move_handler: MovementStyle
@export var teleport_enabled := false
@export var diagonal_move_enabled := false
@export var animation_player: AnimationPlayer
@export_range(-1, 1, 2) var attack_direction = 1


func move_to(new_pos) -> void:
	if move_handler:
		move_handler.move(self, new_pos)
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos,.1)


func shoot() -> void:
	if animation_player and animation_player.has_animation("shoot"):
		animation_player.play("shoot")


func _on_hp_node_hp_changed(new_amt: float) -> void:
	$HealthDisplay.text = str(floori(new_amt))
