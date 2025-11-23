extends Projectile

func _on_tree_entered() -> void:
	if travel_direction < 1: 
		rotation.y = deg_to_rad(180)
		$Cylinder.position.x = .2
