extends MovementStyle

class_name MovementQuickHop

@export var duration := 0.15
@export var hop_height := .12

func move(entity, to_pos) -> void:
	var start_pos = entity.global_position

	# Animate the arc using a Tween
	var tween = entity.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	var peak_y = max(start_pos.y, to_pos.y) + hop_height
	var mid_point = lerp(start_pos, to_pos, 0.5)
	mid_point.y = peak_y
	tween.tween_property(entity, "global_position", mid_point , duration / 2)
	tween.tween_property(entity, "global_position", to_pos, duration / 2)
	
