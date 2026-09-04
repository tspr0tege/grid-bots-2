extends Node

@export var ARENA : Arena
@export var MATCH_CONTROLLER : MatchController

##NOTE: Server needs a tile data object like this:
	#{
		#"team": MatchSettings.teams.TEAM_2,
		#"projectiles": {},
		#"traps": {},
		#"occupant": null,
		#"reserved": false,
		#"traversable": true,
		#"state": FloorTile.tile_states.NORMAL,
	#}
##NOTE: And a character object like this:
	#{
		#"character_id": "",
		#"grid_coords": Vector2i.ZERO,
		#"team": MatchSettings.teams.NEUTRAL,
		#"is_animate": true,
		#"teleport_enabled": false,
		#"diagonal_move_enabled": false,
	#}

func generate_character_id() -> String:
	return str(int(floor(randf() * 10000)))


func init_match() -> void:
	MATCH_CONTROLLER.connect("transmit_ability", request_ability)
	#MATCH_CONTROLLER.connect("transmit_move", request_move)
	MATCH_CONTROLLER.connect("process_tick", _process_tick)
	
	#for x in range(6):
		#var column = []
		#for y in range(3):
			#var new_tile_data = {
				#"team": MatchSettings.teams.TEAM_1 if x < 3 else MatchSettings.teams.TEAM_2,
				#"projectiles": {},
				##"traps": {},
				#"occupant": null,
				#"reserved": false,
				#"traversable": true,
				#"state": FloorTile.tile_states.NORMAL,
			#}
			#column.push_back(new_tile_data)
		#server_state.push_back(column)
	
	#for character in MatchSettings.character_lineup:
		#var new_character = _new_character()
		#for key in character:
			#new_character[key] = character[key]
		#if new_character.character_id == "": 
			#new_character.character_id = generate_character_id()
			#push_error("New character %s was generated without character_id" % new_character.character_id)
		#new_character.grid_coords = character.start_coords
		#server_state[character.start_coords.x][character.start_coords.y].occupant = new_character.character_id
		#
		#print("LocalAuthority.init_match assembled a new character with these details:\n" + str(new_character))
		#characters[new_character.character_id] = new_character
	
	MatchSettings.propagate_ability_list(MatchSettings.player_deck)


func request_ability(caster_id: String, ability_id: String) -> void: 
	#MatchSettings.player_character_id
	var ability: Ability = MatchSettings.ability_list[ability_id]
	
	#CANCEL for player with inadequate energy
	if caster_id == MatchSettings.player_character_id and MatchSettings.player_energy < ability.energy_cost: return
	
	var new_instructions = ability.methods.generate_new_action_plan(caster_id, self)
	
	if caster_id == MatchSettings.player_character_id: #player ability
		var hand_index = MatchSettings.player_hand.find(ability_id)
		MATCH_CONTROLLER.process_player_ability(hand_index, new_instructions)
	else: #NPC ability
		MATCH_CONTROLLER.execute_ability(new_instructions)


func _process_tick(action: TickInstruction) -> void:
	##<TickInstruction> 
	# kickoff_tick, revision, actor_type, 
	# actor_id, action_type, action_instructions
	
	var move_action = TickInstruction.action_types.MOVE
	
	#check if character moving to projectile
	if (action.actor_type == "character" and 
	action.action_type == TickInstruction.action_type_names[move_action]):
		#print("Character moving to new coords")
		var character: Character = MatchSettings.BRIDGE.get_character_by_id(action.actor_id)
		var target_tile: FloorTile = ARENA.get_tile_by_coords(character.grid_coords)
		
		for projectile_id in target_tile.projectiles:
			var projectile = target_tile.projectiles[projectile_id]
			MATCH_CONTROLLER.damage_character(character.character_id, projectile.damage_amount)
			MATCH_CONTROLLER.handle_projectile_collision(projectile.projectile_id)
			
		
	#check if projectile moving to character
	if (action.actor_type == "projectile" and 
	action.action_type == TickInstruction.action_type_names[move_action]):
		#print("Projectile moving to new coords")
		
		var projectile: ProjectileController = MatchSettings.BRIDGE.get_projectile_by_id(action.actor_id)
		var target_tile: FloorTile = ARENA.get_tile_by_coords(projectile.grid_coords)
		
		if  is_instance_valid(target_tile) and target_tile.is_occupied:
			var collision_target: Character = target_tile.occupant
			print("Projectile collision detected with character: " + str(collision_target.character_id))
			MATCH_CONTROLLER.damage_character(collision_target.character_id, projectile.damage_amount)
			MATCH_CONTROLLER.handle_projectile_collision(projectile.projectile_id)
