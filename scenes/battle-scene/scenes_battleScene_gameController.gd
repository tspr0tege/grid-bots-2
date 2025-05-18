extends Node3D

#const BLUE_CHARACTER = preload("res://scenes/battle-scene/blue_character.tres")
#const BLUE_FLOOR_MAT = preload("res://scenes/battle-scene/blue_floor.tres")
#const RED_CHARACTER = preload("res://scenes/battle-scene/red_character.tres")
#const RED_FLOOR_MAT = preload("res://scenes/battle-scene/red_floor.tres")
const FLOOR_TILE = preload("res://scenes/battle-scene/floor_tile.tscn")

var player_character: Node = null
var enemy_character: Node = null
var grid_size = Vector2i(3, 3) # 3x3 tiles per side

const RAY_LENGTH = 100
var screen_tap_origin: Vector2 = Vector2.ZERO

var board_state : Array = []

func _ready():
	player_character = $BlueCharacter
	enemy_character = $RedCharacter
	_init_board_state()

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

func _unhandled_input(event):
	# Events are triggered when the screen is touched, and when the touch ends.
	# Positions are recorded at these two events
	if event is InputEventScreenTouch and event.pressed: 
		#print("Touch screen pressed")
		screen_tap_origin = event.position
	
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
		##var result = space_state.intersect_ray(from, to, [], collision_mask)
		#var result = false
#
		#if result:
			#var clicked_tile = result.collider
			#if "GridTile" in clicked_tile.name:  # Or check group or metadata
				##handle_grid_click(clicked_tile)
				#pass
	

# --- Board State ---

func _init_board_state():
	board_state = []
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x * 2): # Both sides
			var board_state_dict = {
				#grid_coordinates
				#node
				#control
				#state
			}
			var new_tile = FLOOR_TILE.instantiate()
			new_tile.position = Vector3((1.1 * x) + .05, 0, (1.1 * y) + .05)
			new_tile.grid_coordinates = Vector2i(x, y)
			board_state_dict.node = new_tile
			var tile_material = new_tile.get_node("MeshInstance3D").get_surface_override_material(0)
			if (x < grid_size.x):
				board_state_dict.control_group = "BLUE"
				tile_material.albedo_color = Color(0, 0, .9)
			else:
				board_state_dict.control_group = "RED"
				tile_material.albedo_color = Color(.9, .2, .2)
			$Floor.add_child(new_tile)
			row.append(board_state_dict)
			
		board_state.append(row)
	_place_character_on_board(player_character, Vector2i(1, 1))
	_place_character_on_board(enemy_character, Vector2i(4, 1))

func _place_character_on_board(character: Node, pos: Vector2i):
	character.grid_pos = pos
	character.position = board_state[pos.y][pos.x].node.position
	

func _attempt_move(character: Node, target_pos: Vector2i):
	
	print(str(character.name) + " attempting to move to " + str(target_pos))
	#Check valid coordinates
	if not _is_valid_position(target_pos): return
	#Check valid tile
	var target_tile = board_state[target_pos.y][target_pos.x]
	
	if target_tile.node == null: return
	
	#Check Character controlled tile
	if target_tile.control_group != character.control_group: return
	#if target_pos.x > grid_size.x - 1: return
	
	var desired_move = target_pos - character.grid_pos
	# length for above formula is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if desired_move.length() > 1:
		#print("Invalid move. Time to adjust target position")
		if abs(desired_move.x) > abs(desired_move.y):
			desired_move.x /= abs(desired_move.x)
			desired_move.y = 0
		else:
			desired_move.y /= abs(desired_move.y)
			desired_move.x = 0
			
		target_pos = character.grid_pos + desired_move
	
	character.grid_pos = target_pos
	character.move_to(board_state[target_pos.y][target_pos.x].node.position)
	

func _is_valid_position(pos: Vector2i) -> bool:
	return (
		pos.x >= 0 and pos.x < grid_size.x * 2 and
		pos.y >= 0 and pos.y < grid_size.y
	)

# --- Signal Handling ---

func _on_input_signal_received(from_character: Node, action: Dictionary):
	# `action` might be { "type": "move", "dir": Vector2i(1,0) }
	match action.type:
		"move":
			_attempt_move(from_character, action.dir)
		# Future: "attack", "dash", "ability", etc.
	
