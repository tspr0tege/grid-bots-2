extends Node3D

signal match_over(player_wins: bool)
signal update_energy_display(amount: float)
signal player_input(input_data: Dictionary)

const FLOOR_TILE = preload("res://scenes/battle-scene/floor_tile.tscn")
const PLAYER_CHARACTER = preload("res://entities/test-character/player_character.tscn")
const RED_CHARACTER = preload("res://entities/test-character/red_character.tscn")

var player_energy: float = 20.0
var player_character: Node = null
var enemy_character: Node = null
var grid_size = Vector2i(6, 3)

const RAY_LENGTH = 100
var screen_tap_origin: Vector2 = Vector2.ZERO

var arena_tiles : Array = []

func _ready():
	init_arena_tiles()
	SceneManager.load_combatants(self)

	#player_character.input_signal.connect(_on_input_signal_received)
	#enemy_character.input_signal.connect(_on_input_signal_received)


func _process(delta):
	player_energy = clamp(player_energy + delta, 0, 100)
	emit_signal("update_energy_display", player_energy)
	
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
	#elif event is InputEventKey and event.pressed:
		## f=70 g=71
		#match event.keycode:
			#70:
				#print("Hurt player")
				#$BlueCharacter.get_node("HpNode").take_damage(10.5)
			#71:
				#print("Hurt weiner")
				#$RedCharacter.get_node("HpNode").take_damage(20)


func move_dir(target_pos: Vector2i, rule: int) -> Vector2i:
	#rule: 0 = diagonal, 1 = favor x, 2 = favor y
	var direction := Vector2i.ZERO
	if target_pos.x != 0 and rule != 2:
		direction.x = target_pos.x / abs(target_pos.x)
	if target_pos.y != 0 and rule != 1:
		direction.y = target_pos.y / abs(target_pos.y)
	return direction


func is_valid_move(character: Character, to_pos: Vector2i) -> bool:
	#Check Character controlled tile
	var target_tile = get_tile_by_coords(to_pos)
	if target_tile == null: return false
	#Character moving to invalid control_group tile
	if character.control_group != Data.CGs.UNIVERSAL and target_tile.control_group != character.control_group: return false
	#Character moving to occupied tile
	if target_tile.occupant and !is_instance_of(character, Obstacle): return false
	
	#Definitely going to move
	return true


func _attempt_move(character: Character, target_pos: Vector2i) -> bool:
	#Check valid coordinates
	if not is_valid_tile(target_pos): return false
	
	var desired_move = target_pos - character.grid_pos
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if (character.teleport_enabled or desired_move.length() <= 1) and is_valid_move(character, target_pos):
		if is_instance_valid(SceneManager.online_client): transmit_move(character, target_pos)
		return await _execute_move(character, target_pos)
		
	elif character.diagonal_move_enabled and await is_valid_move(character, character.grid_pos + move_dir(desired_move, 0)):
		var coords = character.grid_pos + move_dir(desired_move, 0)
		if is_instance_valid(SceneManager.online_client): transmit_move(character, coords)
		_execute_move(character, coords)
		return true
		
	elif abs(desired_move.x) <= abs(desired_move.y) and await is_valid_move(character, character.grid_pos + move_dir(desired_move, 2)):
		var coords = character.grid_pos + move_dir(desired_move, 2)
		if is_instance_valid(SceneManager.online_client): transmit_move(character, coords)
		_execute_move(character, coords)
		return true
		
	elif await is_valid_move(character, character.grid_pos + move_dir(desired_move, 1)):
		var coords = character.grid_pos + move_dir(desired_move, 1)
		if is_instance_valid(SceneManager.online_client): transmit_move(character, coords)
		_execute_move(character, coords)
		return true
	else:
		return false #invalid move


func transmit_move(character: Character, to_pos: Vector2i) -> void:
	print("Sending local movement input to remote opponent")
	var move_input = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			"opponent_id": Data.opponent_id,
			"action": "MOVE",
			"from_coords": {"x": character.grid_pos.x, "y": character.grid_pos.y},
			"to_coords": {"x": to_pos.x, "y": to_pos.y},
			#validation info (move abilities, etc)
		}
	}
	
	SceneManager.online_client.send_local_input_to_remote(move_input)

func _execute_move(character: Character, to_pos: Vector2i, push := false) -> bool:
	
	var target_tile = get_tile_by_coords(to_pos)
	get_tile_by_coords(character.grid_pos).remove_occupant()
	
	#TODO:Remove "push" from move, and separate it's logic into the ability script. This will require revisiting the obstacle movement logic.
	#obstacle moving to an occupied tile
	if is_instance_of(character, Obstacle) and target_tile.occupant: 
		var obstruction = target_tile.occupant
		var next_tile = to_pos - character.grid_pos
		var push_successful = !is_instance_of(obstruction, Obstacle) and await _execute_move(obstruction, to_pos + next_tile, true)
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


func _attempt_damage(grid_coords: Vector2i, amt: float) -> bool:
	var target_tile = get_tile_by_coords(grid_coords)
	if target_tile == null: return false
	if target_tile.occupant == null: return false
	
	var target_hp_node = target_tile.occupant.get_node("HpNode")
	if !target_hp_node.is_shielded:
		target_hp_node.take_damage(amt)
		return true
	
	var adjusted_dmg = target_hp_node.shield_effect.call(amt)
	if adjusted_dmg > 0:
		target_hp_node.take_damage(amt)
		return true
	
	return false


func _attempt_healing(character: Character, amt: float, overheal := false) -> bool:
	var target_hp_node = character.get_node("HpNode")
	if overheal:
		target_hp_node.take_healing(amt)
		return true
	
	var valid_healing = target_hp_node.MAX_HP - target_hp_node.HP
	if valid_healing > 0:
		target_hp_node.take_healing(valid_healing if valid_healing < amt else amt)
		return true
	
	return false


func _attempt_ability(caster: Character, ability: Ability) -> bool:
	if is_instance_valid(SceneManager.online_client) and caster == player_character:
		transmit_ability(ability.UID)
	return ability.use_ability(caster, %CombatArena)


func transmit_ability(ability_id) -> void:
	print("Sending local ability input to remote opponent")
	var move_input = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			"opponent_id": Data.opponent_id,
			"action": "ABILITY",
			"ability_id": ability_id,
		}
	}
	
	SceneManager.online_client.send_local_input_to_remote(move_input)


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


func place_character_on_board(character: Character, coords: Vector2i):
	var target_tile = get_tile_by_coords(coords)
	character.grid_pos = coords
	character.position = target_tile.position
	target_tile.add_occupant(character)


func search_row(coords: Vector2i, direction: int, search_for: Callable) -> Node3D:
	var target_row = coords.y
	var start_point = coords.x + direction
	var end_point = grid_size.x if direction > 0 else 0
	var search_selection = arena_tiles[target_row].slice(start_point, end_point, direction)
	if end_point == 0: search_selection.push_back(arena_tiles[target_row][0])
	
	for tile in search_selection:
		var found = search_for.call(tile)
		if found: return found
	
	return null


func search_col(col_number: int, search_for: Callable) -> Node3D:
	for i in range(3):
		var found = search_for.call(arena_tiles[col_number][i])
		if found: return found
	
	return null


func for_tile(target_tile: Node3D, control_group: Data.CGs) -> Node3D:
	if target_tile.control_group == control_group:
		return target_tile
	else:
		return null


func for_character(target_tile: Node3D) -> Character:
	return target_tile.occupant


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


func _on_character_death(character: Character) -> void:
	get_tile_by_coords(character.grid_pos).remove_occupant()
	if character == player_character:
		emit_signal("match_over", false)
	if character == enemy_character:
		emit_signal("match_over", true)


func get_tile_by_coords(coords: Vector2i) -> Node3D:
	if !is_valid_tile(coords): return null
	else: return arena_tiles[coords.y][coords.x]

func _attempt_move_shot(from_coords: Vector2i, to_coords: Vector2i, shot: Projectile) -> void:
	var current_tile = get_tile_by_coords(from_coords)
	current_tile.remove_shot(shot.shots_index)
	#shot.grid_coords = to_coords
	var new_tile = get_tile_by_coords(to_coords)
	if new_tile:
		new_tile.add_shot(shot)
	else:
		shot.exit_arena()
		return
	
