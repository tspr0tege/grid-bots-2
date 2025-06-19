extends Node3D

signal match_over(player_wins: bool)

const FLOOR_TILE = preload("res://scenes/battle-scene/floor_tile.tscn")

var player_character: Node = null
var player_team := []
var enemy_character: Node = null
var enemy_team := []
var grid_size = Vector2i(6, 3)

const RAY_LENGTH = 100
var screen_tap_origin: Vector2 = Vector2.ZERO

var arena_tiles : Array = []

func _ready():
	player_character = $PlayerCharacter
	enemy_character = $RedCharacter
	init_arena_tiles()

	#player_character.input_signal.connect(_on_input_signal_received)
	#enemy_character.input_signal.connect(_on_input_signal_received)


func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		_attempt_move(player_character, player_character.grid_pos + Vector2i(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		_attempt_move(player_character, player_character.grid_pos + Vector2i(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		_attempt_move(player_character, player_character.grid_pos + Vector2i(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		_attempt_move(player_character, player_character.grid_pos + Vector2i(0, 1))


func _physics_process(_delta: float) -> void:
	if screen_tap_origin.length() > 0:
		var space_state = get_world_3d().direct_space_state
		var cam = $"../Camera3D"

		var origin = cam.project_ray_origin(screen_tap_origin)
		var end = origin + cam.project_ray_normal(screen_tap_origin) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		#result.collider.grid_coordinates
		if result and ("grid_coordinates" in result.collider):
			#print("Attempting to move to " + str(result.collider.grid_coordinates))			
			_attempt_move(player_character, result.collider.grid_coordinates)
		screen_tap_origin = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	# Events are triggered when the screen is touched, and when the touch ends.
	# Positions are recorded at these two events
	if event is InputEventScreenTouch and event.pressed: 
		#print("Touch screen pressed")
		screen_tap_origin = event.position
	elif event is InputEventKey and event.pressed:
		# f=70 g=71
		match event.keycode:
			70:
				print("Hurt player")
				$BlueCharacter.get_node("HpNode").take_damage(10.5)
			71:
				print("Hurt weiner")
				$RedCharacter.get_node("HpNode").take_damage(20)
		
		#if event is InputEventScreenTouch && !event.pressed:
			#print("Touch screen released")
			#screen_tap_origin = Vector2.ZERO
			#%GameSpaceRaycast
			#var from = $"../Camera3D".project_ray_origin(event.position)
			#var to = from + $"../Camera3D".project_ray_normal(event.position) * 1000
			#var space_state = get_world_3d().direct_space_state #direct_space_state or space?
			#var viewport = get_viewport()
			#var camera = get_viewport().get_camera_3d()
			#var from = camera.project_ray_origin(event.position)
			#var to = from + camera.project_ray_normal(event.position) * 1000
	#
			#var space_state = get_world_3d().direct_space_state
			#var result = space_state.intersect_ray(from, to, [], collision_mask)
			#var result = false
	#
			#if result:
				#var clicked_tile = result.collider
				#if "GridTile" in clicked_tile.name:  # Or check group or metadata
					#handle_grid_click(clicked_tile)
					#pass


func _attempt_move(character: Character, target_pos: Vector2i, push := false) -> bool:
	#Check valid coordinates
	if not is_valid_tile(target_pos): return false
	
	var desired_move = target_pos - character.grid_pos
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if character.teleport_enabled or desired_move.length() <= 1:
		return await _execute_move(character, target_pos, push)
	elif character.diagonal_move_enabled and await _execute_move(character, character.grid_pos + move_dir(desired_move, 0), push):
		return true
	elif abs(desired_move.x) <= abs(desired_move.y) and await _execute_move(character, character.grid_pos + move_dir(desired_move, 2), push):
		return true
	elif await _execute_move(character, character.grid_pos + move_dir(desired_move, 1), push):
		return true
	else:
		return false #invalid move


func _execute_move(character: Character, to_pos: Vector2i, push := false) -> bool:
	#Check Character controlled tile
	var target_tile = get_tile_by_coords(to_pos)
	if character.control_group != Data.CGs.UNIVERSAL and target_tile.control_group != character.control_group: return false
	if target_tile.occupant and !is_instance_of(character, Obstacle): return false
	
	#Definitely going to move
	get_tile_by_coords(character.grid_pos).remove_occupant()
	
	if target_tile.occupant: #obstacle moving to an occupied tile
		var obstruction = target_tile.occupant
		var next_tile = to_pos - character.grid_pos
		var push_successful = !is_instance_of(obstruction, Obstacle) and await _attempt_move(obstruction, to_pos + next_tile)
		if push_successful:
			obstruction.get_node("HpNode").take_damage(character.move_damage)
			target_tile.add_occupant(character)
			character.grid_pos = to_pos
			character.move_to(target_tile.position, push)
		else: #obstacle deals death damage
			var char_hp_node = character.get_node("HpNode")
			character.move_to(target_tile.position)
			await get_tree().create_timer(character.tile_move_speed).timeout
			obstruction.get_node("HpNode").take_damage(char_hp_node.HP / 2)
			char_hp_node.take_damage(char_hp_node.HP)
		return true
	else: #moving to unoccupied tile
		target_tile.add_occupant(character)
		character.grid_pos = to_pos
		character.move_to(target_tile.position, push)
		return true


func _attempt_attack(character: Character) -> void:
	#execute attack animation
	character.shoot()
	#print("Found a target at %s. Target name: %s" % [Vector2i(x, target_row), target_tile.occupant.name])
	var target = linear_search(character, "CHARACTER")
	if target != null:
		target.get_node("HpNode").take_damage(10)


func _attempt_damage(grid_coords: Vector2i, amt: float, on_success: Callable = func():pass) -> bool:
	var target_tile = get_tile_by_coords(grid_coords)
	if target_tile == null: return false
	
	if target_tile.occupant:
		target_tile.occupant.get_node("HpNode").take_damage(amt)
		on_success.call() #Using this in rocket
		return true
	else:
		return false


func _attempt_ability(caster: Character, card) -> void:
	card.use_ability(caster, %CombatArena)


func init_arena_tiles():
	arena_tiles = []
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			var new_tile = FLOOR_TILE.instantiate()
			new_tile.position = Vector3((1.1 * x) + .05, 0, (1.1 * y) + .05)
			new_tile.grid_coordinates = Vector2i(x, y)
			#arena_tiles_dict = new_tile
			new_tile.remove_occupant()
			if (x < grid_size.x / 2):
				new_tile._set_control_group(Data.CGs.BLUE)
			else:
				new_tile._set_control_group(Data.CGs.RED)
			$Floor.add_child(new_tile)
			row.append(new_tile)
			
		arena_tiles.append(row)
	place_character_on_board(player_character, Vector2i(1, 1))
	place_character_on_board(enemy_character, Vector2i(4, 1))


func place_character_on_board(character: Character, pos: Vector2i):
	character.grid_pos = pos
	character.position = arena_tiles[pos.y][pos.x].position
	arena_tiles[pos.y][pos.x].add_occupant(character)


func move_dir(target_pos: Vector2i, rule: int) -> Vector2i:
	#rule: 0 = diagonal, 1 = favor x, 2 = favor y
	var direction := Vector2i.ZERO
	if target_pos.x != 0 and rule != 2:
		direction.x = target_pos.x / abs(target_pos.x)
	if target_pos.y != 0 and rule != 1:
		direction.y = target_pos.y / abs(target_pos.y)
	return direction


func linear_search(from_character: Character, search_for: String):
	var target_row = from_character.grid_pos.y
	var direction = from_character.attack_direction
	var start_point = from_character.grid_pos.x + direction
	var end_point = grid_size.x if direction > 0 else -1
	
	match search_for:
		"TILE":
			for x in range(start_point, end_point, direction):
				var target_tile = arena_tiles[target_row][x]
						
				if from_character.control_group != target_tile.control_group:
					return target_tile
		"CHARACTER":
			for x in range(start_point, end_point, direction):
				var target_tile = arena_tiles[target_row][x]
						
				if is_instance_valid(target_tile.occupant):
					return target_tile.occupant
	
	return null


func tiles_in_group(control_group: Data.CGs) -> Array:
	var matching_tiles := []
	
	for row in arena_tiles:
		for tile in row:
			if tile.control_group == control_group:
				matching_tiles.push_back(tile)
	
	return matching_tiles


func is_valid_tile(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= grid_size.x: return false
	if pos.y < 0 or pos.y >= grid_size.y: return false
	
	var target_tile = arena_tiles[pos.y][pos.x]
	if target_tile == null: return false
		
	return true


func _on_character_death(source: Variant) -> void:
	if source == player_character:
		emit_signal("match_over", false)
	else:
		emit_signal("match_over", true)


func get_tile_by_coords(coords: Vector2i) -> Node3D:
	if !is_valid_tile(coords): return null
	else: return arena_tiles[coords.y][coords.x]

func move_shot(shot):
	pass
