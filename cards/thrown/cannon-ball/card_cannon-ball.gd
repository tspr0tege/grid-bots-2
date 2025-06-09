extends Card

const CANNON_BALL = preload("res://cards/thrown/cannon-ball/cannon_ball.tscn")

const arc_peak := 2.0
const arc_duration := 1.0

func play_card(caster : Character, arena : Node3D) -> void:
	var target_tile_pos = caster.grid_pos
	target_tile_pos.x += 3 * caster.attack_direction
	
	if arena.is_valid_tile(target_tile_pos):
		var target_tile = arena.board_state[target_tile_pos.y][target_tile_pos.x]
		#create ball in scene
		var new_ball = CANNON_BALL.instantiate()
		arena.add_child(new_ball)
		#set it to fly in an arc
		var start_pos = caster.position
		start_pos.y += .5
		var end_pos = target_tile.position
		end_pos.y += .5
		
		var path_curve = Curve3D.new()
		path_curve.add_point(start_pos, Vector3.ZERO, Vector3.UP)
		path_curve.add_point(end_pos, Vector3.UP * 2)
		
		new_ball.get_node("Path").curve = path_curve
		new_ball.get_node("AnimationPlayer").play("launch-arc")
		new_ball.target_grid_tile = target_tile
		#if it hits a player, it does large amounts of damage and cancel floor break
		#emit signal after arc_duration
		#if it lands on the level, break the tile
		new_ball.connect("hit_floor", target_tile.break_tile)
	else:
		#throw cannonball away
		pass
