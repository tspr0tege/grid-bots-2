extends Ability

const CANNON_BALL = preload("res://abilities/thrown/cannon-ball/objects_cannon-ball.tscn")

const arc_peak := 2.0
const arc_duration := 1.0


func validate(caster_id: String, amx: AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	var instructions := {
		"ability_id": UID
	}
	
	var target_tile_coords = caster.grid_pos
	target_tile_coords.x += 3 * caster.attack_direction	
	var target_tile = amx.get_arena_tile_by_coords(target_tile_coords)
	if target_tile == null: 
		instructions.can_cast = false
		instructions.reason = "Throw is outside the arena bounds."
		return instructions

	instructions.can_cast = true
	instructions.vectors = {
		"start_pos": caster.position,
		"target_coords": target_tile.grid_coordinates,
	}
	
	return instructions


func cast(amx : AbilityMethodsExport, instructions: Dictionary) -> void:
	var target_tile = amx.get_arena_tile_by_coords(instructions.vectors.target_coords)
	var new_ball = CANNON_BALL.instantiate()
	amx.add_child_to_arena(new_ball)
	
	#create curve
	var start_pos = instructions.vectors.start_pos
	start_pos.y += .5
	var end_pos = target_tile.position
	end_pos.y += .5	
	var path_curve = Curve3D.new()
	path_curve.add_point(start_pos, Vector3.ZERO, Vector3.UP)
	path_curve.add_point(end_pos, Vector3.UP * 2)
	
	new_ball.get_node("Path").curve = path_curve
	new_ball.get_node("AnimationPlayer").play("launch-arc")
	#if it hits a player, it does large amounts of damage and cancel floor break
	#emit signal after arc_duration
	#if it lands on the floor, break the tile
	new_ball.connect("arc_completed", target_tile.add_shot.bind(new_ball))
	new_ball.connect("hit_floor", target_tile.remove_shot.bind(new_ball.shots_index))
	new_ball.connect("hit_floor", target_tile.break_tile)
	amx.connect_signal_to_arena(new_ball, "attempt_damage", "_attempt_damage")
