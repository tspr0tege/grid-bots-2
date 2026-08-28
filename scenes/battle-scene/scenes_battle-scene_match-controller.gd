class_name MatchController extends Node

signal transmit_ability(caster: String, ability, String)
signal transmit_move(
	character_id: String, 
	#from_coords: Vector2i, 
	to_coords: Vector2i
	)
signal update_energy_display()
signal ability_executed(index: int)

@export var ARENA : Arena
@export var ACTOR_FACTORY : ActorFactory

var RESOLVER : Node
#TODO: remove player_character from this context
var player_character: Node = null
var characters := {}
var projectiles := {}
#traps? effects?



const tick_rate := 40
const tick_queue_size := 2048
#1024 slots = 25.6 seconds
#2048 slots = 51.2 seconds
#4096 slots = 102.4 seconds
var tick_counter_active := false
var tick_accumulator := 0.0
var tick_count := 0
var tick_process_queue: Array = range(tick_queue_size).map(func(i): return [])


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
		var delta_ms = delta * 1000
		tick_accumulator += delta_ms
		while tick_accumulator >= tick_rate:
			tick_accumulator -= tick_rate
			_process_current_tick()


func _process_current_tick() -> void:
	tick_count += 1
	var tick_queue_index = tick_count % tick_queue_size
	var current_tick_actions = tick_process_queue[tick_queue_index]
	
	for action: TickInstruction in current_tick_actions:
		if action.target_tick != tick_count: push_error("Action executing from tick_queue is occuring in the wrong tick.\n Planned tick number: %s\n Actual tick number: %s" % [action.target_tick, tick_count])
		#{ <TickInstruction>
			#target_tick:
			#revision: -> current_revision needs to be stored on actor controller
			#actor_type:
			#actor_id:
			#action_type:
			#action_instructions:
		#}
		
		match action.actor_type:
			"projectile":
				var actor = projectiles[action.actor_id] #Projectile or ProjectileController?
				actor.handle_tick_action(action.action_type, action.action_instructions)
			"character":
				var actor: Character = characters[action.actor_id]
				actor.handle_tick_action(action.action_type, action.action_instructions)
			_:
				push_error("Unhandled actor_type received in _process_current_tick.\n ACTION DICTIONARY:\n" + JSON.stringify(action, "\t"))
		
		pass
	
	#when done:
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


func request_move(character_id: String, target_coords: Vector2i) -> void:
	if not ARENA.is_valid_tile(target_coords): return
	
	transmit_move.emit(character_id, target_coords)


func _execute_move(character_id: String, to_coords: Vector2i, push := false) -> bool:
	var character: Character = characters[character_id]
	var current_tile: FloorTile = ARENA.get_tile_by_coords(character.grid_coords)
	var target_tile: FloorTile = ARENA.get_tile_by_coords(to_coords)
	#TODO: Move tile update logic to CombatArena. Maybe.
	
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
		#TODO: occupant updates should happen by tick count as movement is not instant, and timing will matter.
		current_tile.remove_occupant()
		target_tile.add_occupant(character)
		character.grid_coords = to_coords
		#TODO: update move_to function to receive tile only, and update character grid_coords
		character.move_to(target_tile.position, push)
		return true


func update_character_coords(character_id: String, to_coords: Vector2i) -> void:
	#var character: Character = characters[character_id]
	#var target_tile: FloorTile = ARENA.get_tile_by_coords(to_coords)
	#var current_tile: FloorTile = ARENA.get_tile_by_coords(character.grid_coords)
	#change character grid coords
	#remove occupant from current tile
	#add occupant in new tile
	#NOTE: character will already be moving
	pass


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
