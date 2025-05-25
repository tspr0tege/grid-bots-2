extends Node3D

class_name Character

var grid_pos : Vector2i
var health_display : Label3D

@export var control_group := "NONE"
@export var move_handler: MovementStyle
@export var teleport_enabled := false
@export var diagonal_move_enabled := false
@export var animation_player: AnimationPlayer
@export var display_health: bool = false
@export_range(-1, 1, 2) var attack_direction = 1


func _ready() -> void:
	if display_health:
		health_display = Label3D.new()
		health_display.offset.y = -50
		health_display.set_billboard_mode(1)
		health_display.no_depth_test = true
		health_display.text = str(floori($HpNode.HP))
		add_child(health_display)


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
	if display_health:
		health_display.text = str(floori(new_amt))


func _handle_character_death() -> void:
	queue_free()
