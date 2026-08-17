extends Node

signal transmit_ability(input_data: Dictionary)
signal transmit_move(from_coords: Vector2i, to_coords: Vector2i)
signal update_energy_display()
signal ability_executed(index: int)

@export var ARENA : Node3D
@export var CHARACTER_FACTORY : Node

var RESOLVER : Node
#STATE

var player_character: Node = null
var characters: Dictionary = {}


var AMX: AbilityMethodsExport

func _ready():
	if MatchData.is_online_match:
		RESOLVER = $OnlineAuthority	
		process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		RESOLVER = $LocalAuthority
		process_mode = Node.PROCESS_MODE_PAUSABLE
	
	AMX = AbilityMethodsExport.new(ARENA, self)
	
	SoundManager.play_bgm_stream("BATTLE")


func _process(delta):
	var energy_inc = delta * MatchData.player_energy_accum_rate
	var new_energy_level = MatchData.player_energy + energy_inc
	MatchData.player_energy = clamp(new_energy_level , 0, MatchData.player_max_energy)
	update_energy_display.emit()


func _on_combat_arena_ready() -> void:
	for character in MatchData.character_lineup:
		add_new_character(character)


func handle_move_by_direction(coords: Vector2i) -> void:
	_attempt_move(player_character, player_character.grid_coords + coords)


func handle_move_by_coords(coords: Vector2i) -> void:
	_attempt_move(player_character, coords)


func _attempt_move(character: Character, target_coords: Vector2i) -> bool:
	#Check valid coordinates
	if not ARENA.is_valid_tile(target_coords): return false
	
	var desired_move = target_coords - character.grid_coords
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if (character.teleport_enabled or desired_move.length() <= 1) and ARENA.is_valid_move(character, target_coords):
		transmit_move.emit(character.grid_coords, target_coords)
		return await _execute_move(character, target_coords)
		
	elif character.diagonal_move_enabled and ARENA.is_valid_move(character, character.grid_coords + ARENA.move_dir(desired_move, 0)):
		var coords = character.grid_coords + ARENA.move_dir(desired_move, 0)
		transmit_move.emit(character.grid_coords, coords)
		_execute_move(character, coords)
		return true
		
	elif abs(desired_move.x) <= abs(desired_move.y) and ARENA.is_valid_move(character, character.grid_coords + ARENA.move_dir(desired_move, 2)):
		var coords = character.grid_coords + ARENA.move_dir(desired_move, 2)
		transmit_move.emit(character.grid_coords, coords)
		_execute_move(character, coords)
		return true
		
	elif ARENA.is_valid_move(character, character.grid_coords + ARENA.move_dir(desired_move, 1)):
		var coords = character.grid_coords + ARENA.move_dir(desired_move, 1)
		transmit_move.emit(character.grid_coords, coords)
		_execute_move(character, coords)
		return true
	else:
		return false #invalid move


func _execute_move(character: Character, to_coords: Vector2i, push := false) -> bool:
	var target_tile = ARENA.get_tile_by_coords(to_coords)
	#TODO: Move tile update logic to CombatArena. Maybe.
	ARENA.get_tile_by_coords(character.grid_coords).remove_occupant()
	
	#obstacle moving to an occupied tile
	#TODO:Remove "push" from move, and separate it's logic into the ability script. This will require revisiting the obstacle movement logic.
	if is_instance_of(character, Obstacle) and target_tile.occupant: 
		var obstruction = target_tile.occupant
		var next_tile = to_coords - character.grid_coords
		var push_successful = !is_instance_of(obstruction, Obstacle) and await _execute_move(obstruction, to_coords + next_tile, true)
		if push_successful:
			obstruction.get_node("HpNode").take_damage(character.move_damage)
			target_tile.add_occupant(character)
			character.grid_coords = to_coords
			character.move_to(target_tile.position, push)
		else: #obstacle deals death damage
			var char_hp_node = character.get_node("HpNode")
			character.move_to(target_tile.position)
			await get_tree().create_timer(character.tile_move_speed).timeout
			obstruction.get_node("HpNode").take_damage(char_hp_node.HP / 2)
			char_hp_node.take_damage(char_hp_node.HP)
		return true
	else: #moving to unoccupied tile
		#TODO: occupant updates should happen in move_to function, or by tick count as movement is not instant, and timing could matter.
		target_tile.add_occupant(character)
		character.grid_coords = to_coords
		character.move_to(target_tile.position, push)
		return true


func search_for_target(source: Character, searching_for: String) -> void:
	match searching_for:
		"PLAYER_IN_ROW":
			if player_character.grid_coords.y == source.grid_coords.y:
				source.target_result(true)
			else:
				source.target_result(false)
		_:
			print("No idea what %s is searching for." % source.id)


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


func attempt_ability(caster_id, ability_id) -> void:
	#Run can_cast - if false, nothing else happens
	#if true - 
	#run wind-up animation
	#TODO: wind-up function in character base class - plays wind-up portion of ability's target animation (if available)
	#signal transmit_ability
	pass


func execute_ability(caster_id, ability_id, hand_index: int = -1) -> void:
	#called by authority resolver
	#hand_index passed in on specific ability opcode
	var ability: Ability = MatchData.ability_list[ability_id]
	
	if hand_index >= 0:
	#TODO: attempt_ability will no longer resolve locally, like this. 
	#New flow: 
		#attempt_ability -> initiates wind-up animation, sends resolver request
		#await resolver response
		#resolver will call execute directly on remote client and local client, with ability_index on local
		#signal emits from execute to update hand, UI, and energy
		MatchData.player_energy -= ability.energy_cost
		MatchData.discard(hand_index)
		MatchData.draw_card(hand_index)
		ability_executed.emit(hand_index)
		#update_ability_UI_button(index)
		#TODO: resume player animation from wind-up
	pass


func cancel_ability() -> void:
	#reset player_animation
	pass


func get_characters_by_group(control_group: MatchData.teams) -> Array:
	var characters_in_group = []
	for key in characters.keys():
		if characters[key].control_group == control_group:
			characters_in_group.push_back(characters[key])
	return characters_in_group


func add_new_character(character_instructions: Dictionary):
	var new_character = CHARACTER_FACTORY.place_character_on_board(character_instructions)
	if new_character:
		new_character.id = str(floor(randf() * 10000)) 
		characters[new_character.id] = new_character
	
	#TODO: Move connection logic into character receipt function in Nakama Client
	if MatchData.is_online_match and character_instructions.role == MatchData.roles.OPPOSING_PLAYER:
		SceneManager.online_client.connect("opponent_move", func(coords):
			_execute_move.call(new_character, coords)
			)
		
		SceneManager.online_client.connect("opponent_use_ability", func(instructions): 
			instructions.caster_id = new_character.id
			execute_ability.call(instructions)
			)
	
	return new_character


func handle_character_death(character: Character) -> void:
	AMX.get_arena_tile_by_coords(character.grid_coords).remove_occupant()
	if character == player_character:
		player_lost()
		return
	
	characters.erase(character.id)
	var characters_remaining_in_group = get_characters_by_group(character.control_group)
	if character.control_group == MatchData.player_team and characters_remaining_in_group.size() < 1:
		push_error("The player's control group was completely wiped out without triggering the player_lost function.")
	elif character.control_group == MatchData.opposing_team(MatchData.player_team) and characters_remaining_in_group.size() < 1:
		push_warning("Player victory triggered by default of all opponents being destroyed.")
		opponent_lost()


func player_lost() -> void:
	get_tree().paused = true
	%MatchResult.text = "You Lost!"
	$"../CanvasLayer/MatchOver".visible = true


func opponent_lost() -> void:
	get_tree().paused = true
	%MatchResult.text = "You Win!"
	$"../CanvasLayer/MatchOver".visible = true
