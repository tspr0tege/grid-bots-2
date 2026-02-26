extends Node

signal player_input(input_data: Dictionary)
signal update_energy_display(energy_level)

@export var NET_CLIENT : Node
@export var ARENA : Node3D
@export var CHARACTER_FACTORY : Node
# PLAYER_CONTROLLER
# UI

var player_energy: float = 20.0
var player_character: Node = null
var characters: Dictionary = {}

var AMX: AbilityMethodsExport

func _ready():
	AMX = AbilityMethodsExport.new(ARENA, self)


func _process(delta):
	player_energy = clamp(player_energy + delta * 2, 0, 100)
	emit_signal("update_energy_display", player_energy)


func _on_combat_arena_ready() -> void:
	for character in SceneManager.match_settings.characters:
		var new_character = CHARACTER_FACTORY.place_character_on_board(character)
		if new_character:
			new_character.id = str(floor(randf() * 10000)) 
			characters[new_character.id] = new_character


func handle_move_by_direction(coords: Vector2i) -> void:
	_attempt_move(player_character, player_character.grid_pos + coords)


func handle_move_by_coords(coords: Vector2i) -> void:
	print("Attempting to move to " + str(coords))
	_attempt_move(player_character, coords)



func _attempt_move(character: Character, target_pos: Vector2i) -> bool:
	#Check valid coordinates
	if not ARENA.is_valid_tile(target_pos): return false
	
	var desired_move = target_pos - character.grid_pos
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if (character.teleport_enabled or desired_move.length() <= 1) and ARENA.is_valid_move(character, target_pos):
		if is_instance_valid(SceneManager.online_client): transmit_move(character, target_pos)
		return await _execute_move(character, target_pos)
		
	elif character.diagonal_move_enabled and ARENA.is_valid_move(character, character.grid_pos + ARENA.move_dir(desired_move, 0)):
		var coords = character.grid_pos + ARENA.move_dir(desired_move, 0)
		if is_instance_valid(SceneManager.online_client): transmit_move(character, coords)
		_execute_move(character, coords)
		return true
		
	elif abs(desired_move.x) <= abs(desired_move.y) and ARENA.is_valid_move(character, character.grid_pos + ARENA.move_dir(desired_move, 2)):
		var coords = character.grid_pos + ARENA.move_dir(desired_move, 2)
		if is_instance_valid(SceneManager.online_client): transmit_move(character, coords)
		_execute_move(character, coords)
		return true
		
	elif ARENA.is_valid_move(character, character.grid_pos + ARENA.move_dir(desired_move, 1)):
		var coords = character.grid_pos + ARENA.move_dir(desired_move, 1)
		if is_instance_valid(SceneManager.online_client): transmit_move(character, coords)
		_execute_move(character, coords)
		return true
	else:
		return false #invalid move


func transmit_move(character: Character, to_pos: Vector2i) -> void:
	#print("Sending local movement input to remote opponent")
	var move_input = {
		#"opponent_id": Data.opponent_id,
		"action": "MOVE",
		"vectors":{
			"from_coords": character.grid_pos,
			"to_coords": to_pos,
		}
		#validation info (move abilities, etc)
	}
	
	SceneManager.online_client.send_local_input_to_remote(move_input)


func _execute_move(character: Character, to_pos: Vector2i, push := false) -> bool:
	
	var target_tile = ARENA.get_tile_by_coords(to_pos)
	ARENA.get_tile_by_coords(character.grid_pos).remove_occupant()
	
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
	var target_tile = ARENA.get_tile_by_coords(grid_coords)
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
	#if is_instance_valid(SceneManager.online_client) and caster == player_character:
		#transmit_ability(ability.UID)
	#return ability.use_ability(caster, %CombatArena)
	var instructions = ability.validate(caster.id, AMX)
	if instructions.can_cast == false:
		print(instructions.reason)
		return false
	else:
		player_input.emit(instructions.duplicate(true))
		_execute_ability(instructions)
		return true


func _execute_ability(instructions: Dictionary) -> void:
	print("Instructions in _execute_ability: " + str(instructions))
	
	if instructions.has("caster_id"):
		instructions.caster = characters[instructions.caster_id]
	
	match instructions.target_type:
		"TILE":
			instructions.target = ARENA.get_tile_by_coords(instructions.vectors.target_coords)
		"OCCUPANT":
			if instructions.vectors.target_coords != null:
				instructions.target = ARENA.get_tile_by_coords(instructions.vectors.target_coords).occupant
			else:
				instructions.target = null
		_:
			print("_execute_ability received instructions without a target_type. Instructions: " + str(instructions))
	var ability = Data.ability_deck[instructions.ability_id]
	ability.cast(AMX, instructions)


func transmit_ability(ability_id) -> void:
	print("Sending local ability input to remote opponent")
	var move_input = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			#"opponent_id": Data.opponent_id,
			"action": "ABILITY",
			"ability_id": ability_id,
		}
	}
	
	SceneManager.online_client.send_local_input_to_remote(move_input)
