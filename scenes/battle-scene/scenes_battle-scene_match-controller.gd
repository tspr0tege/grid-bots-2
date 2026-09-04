class_name MatchController extends Node

@onready var tick_label: Label = $"../CanvasLayer/GridContainer/PlaySpace/DebugPanel/VBoxContainer/Tick"
@onready var delta_ms_label: Label = $"../CanvasLayer/GridContainer/PlaySpace/DebugPanel/VBoxContainer/DeltaMs"

signal transmit_ability(caster: String, ability, String)
signal transmit_move(
	character_id: String, 
	#from_coords: Vector2i, 
	to_coords: Vector2i
	)
signal update_energy_display()
signal ability_executed(index: int)
signal process_tick(action: TickInstruction)

@export var ARENA : Arena
@export var ACTOR_FACTORY : ActorFactory

var RESOLVER : Node
#TODO: remove player_character from this context
var player_character: Node = null
var characters := {}
var projectiles := {}
#traps? effects?



var tick_counter_active := false
const tick_rate := 40
const tick_duration := 1.0 / tick_rate
const tick_queue_size := 2048
#1024 slots = 25.6 seconds
#2048 slots = 51.2 seconds
#4096 slots = 102.4 seconds
var tick_accumulator := 0.0
var tick_count := 0
var tick_process_queue: Array = range(tick_queue_size).map(func(_i): return [])


func _ready():
	if MatchSettings.is_online_match:
		RESOLVER = $OnlineAuthority
		process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		RESOLVER = $LocalAuthority
		process_mode = Node.PROCESS_MODE_PAUSABLE
		for character in MatchSettings.character_lineup:
			character.character_id = $LocalAuthority.generate_character_id()
	
	RESOLVER.init_match()
	MatchSettings.BRIDGE = AbilityMethodsBridge.new(ARENA, self)
	
	SoundManager.play_bgm_stream("BATTLE")


func _process(delta):
	var energy_increment = delta * MatchSettings.player_energy_accum_rate
	var new_energy_level = MatchSettings.player_energy + energy_increment
	MatchSettings.player_energy = clamp(new_energy_level , 0, MatchSettings.player_max_energy)
	update_energy_display.emit()
	
	if tick_counter_active:
		#var delta_ms = int(delta * 1000)
		tick_accumulator += delta
		#delta_ms_label.text = "Delta MS: " + str(delta_ms)
		while tick_accumulator >= tick_duration:
			tick_accumulator -= tick_duration
			_process_current_tick()


func _process_current_tick() -> void:
	tick_count += 1
	tick_label.text = "tick_count: " + str(tick_count)
	var tick_queue_index = tick_count % tick_queue_size
	var current_tick_actions = tick_process_queue[tick_queue_index]
	
	for action: TickInstruction in current_tick_actions:
		if action.kickoff_tick != tick_count: push_error("Action executing from tick_queue is occuring in the wrong tick.\n Planned tick number: %s\n Actual tick number: %s" % [action.kickoff_tick, tick_count])
		#{ <TickInstruction>
			#kickoff_tick:
			#revision: -> current_revision on ProjectileController
			#actor_type:
			#actor_id:
			#action_type:
			#action_instructions:
		#}
		
		match action.actor_type:
			"projectile":
				if !projectiles.has(action.actor_id): continue #projectile has been deleted
				var projectile: ProjectileController = projectiles[action.actor_id] #Projectile or ProjectileController?
				if projectile.current_revision != action.revision: 
					push_warning("projectile.current_revision does not match action.revision")
					continue #projectile has updated instructions
				projectile.handle_tick_action(action.action_type, action.action_instructions)
				process_tick.emit(action)
			"character":
				var character: Character = characters[action.actor_id]
				character.handle_tick_action(action.action_type, action.action_instructions)
				process_tick.emit(action)
			_:
				push_error("Unhandled actor_type received in _process_current_tick.\n ACTION DICTIONARY:\n" + JSON.stringify(action, "\t"))
	
	tick_process_queue[tick_queue_index] = []


func _on_combat_arena_ready() -> void:
	for character in MatchSettings.character_lineup:
		var new_character = ACTOR_FACTORY.spawn_character(character)
		var target_tile = ARENA.get_tile_by_coords(new_character.grid_coords)
		if character.role == MatchSettings.roles.PLAYER_CHARACTER:
			player_character = new_character
		
		characters[character.character_id] = new_character
		new_character.position = target_tile.position
		ARENA.add_child(new_character)
		target_tile.occupant = new_character


func handle_move_by_direction(coords: Vector2i) -> void:
	request_move(player_character.character_id, player_character.grid_coords + coords)


func handle_move_by_coords(coords: Vector2i) -> void:
	request_move(player_character.character_id, coords)


func handle_projectile_collision(projectile_id: String) -> void:
	var projectile: ProjectileController = projectiles[projectile_id]
	projectile.handle_tick_action("collision", {})


func request_move(character_id: String, target_coords: Vector2i) -> void:
	#Check valid coordinates
	if not ARENA.is_valid_tile(target_coords): return
	
	var moving_character: Character = characters[character_id]
	#var from_coords = character.grid_coords
	var desired_move = target_coords - moving_character.grid_coords
	
	# desired_move.length is 1.0 for adjacent tiles, and roughly 1.4 for diagonals
	if (moving_character.teleport_enabled or desired_move.length() <= 1) and _is_valid_move(moving_character, target_coords):
		transmit_move.emit(character_id, target_coords)
		execute_move(moving_character.character_id, target_coords)
		#TODO: transmit_move also needs to mount the move somewhere for "undo" if invalidated by the server.
	elif (moving_character.diagonal_move_enabled and 
	_is_valid_move(moving_character, moving_character.grid_coords + _move_dir(desired_move, 0))):
		var coords = moving_character.grid_coords + _move_dir(desired_move, 0)
		transmit_move.emit(character_id, coords)
		execute_move(character_id, coords)
		
	elif (abs(desired_move.x) <= abs(desired_move.y) and
	 _is_valid_move(moving_character, moving_character.grid_coords + _move_dir(desired_move, 2))):
		var coords = moving_character.grid_coords + _move_dir(desired_move, 2)
		transmit_move.emit(character_id, coords)
		execute_move(character_id, coords)
		
	elif _is_valid_move(moving_character, moving_character.grid_coords + _move_dir(desired_move, 1)):
		var coords = moving_character.grid_coords + _move_dir(desired_move, 1)
		transmit_move.emit(character_id, coords)
		execute_move(character_id, coords)
	else:
		#push_warning("Invalid move request for %s." % character.character_id)
		return


func _is_valid_move(character: Character, to_coords: Vector2i) -> bool:
	var target_tile = ARENA.get_tile_by_coords(to_coords)
	#Character moving to invalid team tile
	if (character.team != MatchSettings.teams.UNIVERSAL and
	 target_tile.team != character.team): 
		return false
	#Character moving to occupied tile
	if target_tile.occupant: return false
	if target_tile.reserved: return false
	if !target_tile.traversable: return false
	
	#Definitely going to move
	return true


func _move_dir(target_coords: Vector2i, rule: int) -> Vector2i:
	#rule: 0 = diagonal, 1 = favor x, 2 = favor y
	var direction := Vector2i.ZERO
	if target_coords.x != 0 and rule != 2:
		direction.x = target_coords.x / abs(target_coords.x)
	if target_coords.y != 0 and rule != 1:
		direction.y = target_coords.y / abs(target_coords.y)
	return direction


func execute_move(character_id: String, to_coords: Vector2i) -> void:
	var character: Character = characters[character_id]
	var character_move_speed = character.tile_move_speed
	
	var target_tile: FloorTile = ARENA.get_tile_by_coords(to_coords)
	
	var tick_update := TickInstruction.new(
		int(character_move_speed / 2),
		1,
		"character",
		character_id, 
		TickInstruction.action_types.MOVE,
		{ #instructions needed for update
			"to_coords": to_coords
		} 
	)
	
	MatchSettings.BRIDGE.load_tick_instructions([tick_update])
	target_tile.reserved = true
	character.move_to(target_tile.position)


func update_character_coords(character_id: String, to_coords: Vector2i) -> void:
	var character: Character = characters[character_id]
	var target_tile: FloorTile = ARENA.get_tile_by_coords(to_coords)
	var current_tile: FloorTile = ARENA.get_tile_by_coords(character.grid_coords)
	#NOTE: character will already be moving
	current_tile.remove_occupant()
	target_tile.add_occupant(character)
	character.grid_coords = to_coords


func search_for_target(source: Character, searching_for: String) -> void:
	match searching_for:
		"PLAYER_IN_ROW":
			if player_character.grid_coords.y == source.grid_coords.y:
				source.target_result(true)
			else:
				source.target_result(false)
		_:
			print("No idea what %s is searching for." % source.character_id)


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

#TODO: change this is a single function for healing and damage
func damage_character(character_id: String, dmg_amt: float) -> void:
	var target_character = characters[character_id]
	var target_hp_node = target_character.get_node("HpNode")
	target_hp_node.take_damage(dmg_amt)


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
	var ability = MatchSettings.ability_list[ability_id]
	
	if (caster_id == MatchSettings.player_character_id and 
	MatchSettings.player_energy < ability.energy_cost): #Not enough energy
		return 
	
	#run wind-up animation
	#TODO: wind-up function in character base class - plays wind-up portion of ability's target animation (if available)
	transmit_ability.emit(caster_id, ability_id)


func process_player_ability(hand_index: int, instructions: Dictionary) -> void:
	var ability_id = instructions.ability_id
	var ability: Ability = MatchSettings.ability_list[ability_id]
	MatchSettings.player_energy -= ability.energy_cost
	MatchSettings.discard(hand_index)
	MatchSettings.draw_card(hand_index)
	ability_executed.emit(hand_index) #update UI
	#continue animation
	execute_ability(instructions)


func execute_ability(instructions: Dictionary) -> void:
	var ability_id = instructions.ability_id
	#var caster_id = instructions.caster_id
	#called by authority resolver
	var ability: Ability = MatchSettings.ability_list[ability_id]
	
	ability.methods.cast(instructions)


func cancel_ability() -> void:
	#TODO: reset player_animation
	pass


func get_characters_by_group(team: MatchSettings.teams) -> Array:
	var characters_in_group = []
	for key in characters.keys():
		if characters[key].team == team:
			characters_in_group.push_back(characters[key])
	return characters_in_group


func handle_character_death(character: Character) -> void:
	#MatchSettings.BRIDGE.get_arena_tile_by_coords(character.grid_coords).remove_occupant()
	if character == player_character:
		player_lost()
		return
	
	characters.erase(character.character_id)
	var characters_remaining_in_group = get_characters_by_group(character.team)
	if character.team == MatchSettings.player_team and characters_remaining_in_group.size() < 1:
		push_error("The player's control group was completely wiped out without triggering the player_lost function.")
	elif character.team == MatchSettings.opposing_team(MatchSettings.player_team) and characters_remaining_in_group.size() < 1:
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
