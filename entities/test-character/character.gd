extends Node3D

class_name Character

var grid_pos : Vector2i
@export var control_group := "NONE"
@export var move_handler: MovementStyle

func move_to(new_pos) -> void:
	if move_handler:
		move_handler.move(self, new_pos)
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos,.1)
	

func _on_hp_node_hp_changed(new_amt: float) -> void:
	$HealthDisplay.text = str(floori(new_amt))
	
