extends Node3D

const FLOOR_TILE = preload("res://scenes/battle-scene/floor_tile.tscn")
const ROCK_CUBE = preload("res://cards/summons/rock-cube/rock_cube.tscn")
const PUNCH = preload("res://cards/melee/punch/punch.tscn")

var player_character: Node = null
var enemy_character: Node = null
var grid_size = Vector2i(6, 3) # 3x3 tiles per side

const RAY_LENGTH = 100
var screen_tap_origin: Vector2 = Vector2.ZERO

var board_state : Array = []

func _ready():
	player_character = $PlayerCharacter
	enemy_character = $RedCharacter
	init_board_state()

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


func _attempt_move(character: Character, target_pos: Vector2i) -> bool:
	#print(str(character.name) + " attempting to move to " + str(target_pos))
	
	#Check valid coordinates
	if not is_valid_tile(target_pos): return false
	
	var desired_move = target_pos - character.grid_pos
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if character.teleport_enabled or desired_move.length() <= 1:
		return _execute_move(character, target_pos)
	elif character.diagonal_move_enabled and _execute_move(character, character.grid_pos + move_dir(desired_move, 0)):
		return true
	elif abs(desired_move.x) <= abs(desired_move.y) and _execute_move(character, character.grid_pos + move_dir(desired_move, 2)):
		return true
	elif _execute_move(character, character.grid_pos + move_dir(desired_move, 1)):
		return true
	else:
		print("Character %s unable to move!" % character.name)
		return false


func _execute_move(character: Character, pos: Vector2i) -> bool:
	#Check Character controlled tile
	var target_tile = board_state[pos.y][pos.x]
	if character.control_group != "UNIVERSAL" and target_tile.control_group != character.control_group: return false
	if target_tile.occupant: return false
	board_state[character.grid_pos.y][character.grid_pos.x].occupant = null
	character.grid_pos = pos
	board_state[pos.y][pos.x].occupant = character
	character.move_to(board_state[pos.y][pos.x].node.position)
	return true


func _attempt_attack(character: Character) -> void:
	#execute attack animation
	character.shoot()
	#print("Found a target at %s. Target name: %s" % [Vector2i(x, target_row), target_tile.occupant.name])
	var target = linear_search(character)
	if target != null:
		target.get_node("HpNode").take_damage(10)


func _attempt_ability(character: Character, card) -> void:
	match card:
		"ROCK_CUBE":
			print("Casting Rock Cube")
			var rock_cube_pos = character.grid_pos + Vector2i(character.attack_direction, 0)
			var new_rock_cube = ROCK_CUBE.instantiate()
			%CombatArena.add_child(new_rock_cube)
			place_character_on_board(new_rock_cube, rock_cube_pos)
		"PUNCH":
			print("Attempting punch")
			var new_punch = PUNCH.instantiate()
			new_punch.connect("attempt_push", _attempt_push)
			player_character.add_child(new_punch)
			new_punch.global_rotation = Vector3.ZERO
		"CAPTURE_TILE":
			print("Attempting to capture tile")
		_:
			print("Unknown ability: " + str(card))


func _attempt_push(pos: Vector2i, dir: Vector2i, push_dmg: float = 0.0) -> bool:
	var push_to = pos + dir
	if !is_valid_tile(pos) or !is_valid_tile(push_to): return false
	
	var target : Character = board_state[pos.y][pos.x].occupant
	var target_tile = board_state[push_to.y][push_to.x]
	
	if target == null: return false
	if !is_instance_of(target, Character): return false
	
	if target.is_in_group("Obstacles"): #always moves
		
		#move to unoccupied tile
		if _attempt_move(target, push_to): return true
		
		#move to tile occupied by obstacle
		var obstruction : Character = target_tile.occupant
		target.move_to(target_tile.node.position)
		board_state[pos.y][pos.x].occupant = null
		await get_tree().create_timer(target.tile_move_speed).timeout
		if obstruction.is_in_group("Obstacles"):
			var target_hp_node = target.get_node("HpNode")
			obstruction.get_node("HpNode").take_damage(target_hp_node.HP / 2)
			target_hp_node.take_damage(target_hp_node.HP)
			return true
		#move to tile occupied by non-obstacle (cause knockback)
		else:
			if _attempt_knockback(obstruction, dir):
				obstruction.get_node("HpNode").take_damage(push_dmg)
				target_tile.occupant = target
				return true
			else:
				var target_hp_node = target.get_node("HpNode")
				obstruction.get_node("HpNode").take_damage(target_hp_node.HP / 2)
				target_hp_node.take_damage(target_hp_node.HP)
				return true
	else: #all other characters
		target.get_node("HpNode").take_damage(push_dmg)
		return _attempt_move(target, push_to)
	#if  is_instance_valid(target) and target.is_in_group("Character"):
		#_attempt_move(target, move_to)


func _attempt_knockback(character: Character, dir: Vector2i) -> bool:
	var attempted_pos = character.grid_pos + dir
	return _attempt_move(character, attempted_pos)


func init_board_state():
	board_state = []
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			var board_state_dict = {
				#control_group
				#occupant
				#node
				#state
			}
			var new_tile = FLOOR_TILE.instantiate()
			new_tile.position = Vector3((1.1 * x) + .05, 0, (1.1 * y) + .05)
			new_tile.grid_coordinates = Vector2i(x, y)
			board_state_dict.node = new_tile
			board_state_dict.occupant = null
			var tile_material = new_tile.get_node("MeshInstance3D").get_surface_override_material(0)
			if (x < grid_size.x / 2):
				board_state_dict.control_group = "BLUE"
				tile_material.albedo_color = Color(0, 0, .9)
			else:
				board_state_dict.control_group = "RED"
				tile_material.albedo_color = Color(.9, .2, .2)
			$Floor.add_child(new_tile)
			row.append(board_state_dict)
			
		board_state.append(row)
	place_character_on_board(player_character, Vector2i(1, 1))
	place_character_on_board(enemy_character, Vector2i(4, 1))


func place_character_on_board(character: Character, pos: Vector2i):
	character.grid_pos = pos
	character.position = board_state[pos.y][pos.x].node.position
	board_state[pos.y][pos.x].occupant = character


func move_dir(target_pos: Vector2i, rule: int) -> Vector2i:
	#rule: 0 = diagonal, 1 = favor x, 2 = favor y
	var direction := Vector2i.ZERO
	if target_pos.x != 0 and rule != 2:
		direction.x = target_pos.x / abs(target_pos.x)
	if target_pos.y != 0 and rule != 1:
		direction.y = target_pos.y / abs(target_pos.y)
	return direction


func linear_search(from_character: Character):
	var target_row = from_character.grid_pos.y
	var direction = from_character.attack_direction
	var start_point = from_character.grid_pos.x + direction
	var end_point = grid_size.x if direction > 0 else -1
	
	for x in range(start_point, end_point, direction):
			var target_tile = board_state[target_row][x]
			if is_instance_valid(target_tile.occupant):
				return target_tile.occupant
	
	return null


func is_valid_tile(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x > grid_size.x:
		push_warning("Attempted move outside of valid grid constraints on the X axis. X value = " + str(pos.x))
		return false
	
	if pos.y < 0 or pos.y > grid_size.y:
		push_warning("Attempted move outside of valid grid constraints on the Y axis. Y value = " + str(pos.y))
		return false
	
	var target_tile = board_state[pos.y][pos.x]
	
	if target_tile.node == null: 
		push_error("Attempted move targets a grid tile that is null. Grid position: " + str(pos))
		return false
		
	return true
