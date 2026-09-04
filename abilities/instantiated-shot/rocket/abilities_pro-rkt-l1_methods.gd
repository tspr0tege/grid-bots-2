## ROCKET
class_name pro_rkt_l1_methods
extends AbilityMethodsRegister

@export var test_variable := false

const ROCKET = preload("res://abilities/instantiated-shot/rocket/pro-rkt-l1_model.tscn")
const CONTROLLER = preload("res://abilities/instantiated-shot/rocket/abilities_pro-rkt-l1_controller.gd")

func generate_new_action_plan(caster_id: String, LocalAuthority: Node) -> Dictionary:
	var caster: Character = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var new_projectile_id: String = LocalAuthority.generate_character_id()
	var instructions = _new_instructions(caster_id, "pro-rkt-l1", new_projectile_id)
	## instructions
	#{
		#"caster_id": caster_id,
		#"ability_id": "pro-rkt-l1",
		#"projectile_id": new_projectile_id,
		#"start_coords": caster.grid_coords,
		#"action_plan": [], #action_plan will be a series of TickInstructions
	#}
	
	#setup travel by tick count (at tick n, speed in position/tick, as a function of the width of a tile.
	var start_coords: Vector2i = caster.grid_coords
	start_coords.x += 1
	var ticks_per_tile := 20
	var tick_accumulator: int = 0
	
	while start_coords.x <= 6:
		var move_to_coords = start_coords + Vector2i(1,0)
		
		var action_plan_step = TickInstruction.new(
			tick_accumulator,
			instructions.revision,
			"projectile",
			new_projectile_id,
			TickInstruction.action_types.MOVE,
			{
				"from_coords": start_coords,
				"to_coords": move_to_coords,
				"move_speed": ticks_per_tile
			}
		)
		
		instructions.action_plan.push_back(action_plan_step)
		tick_accumulator += ticks_per_tile
		ticks_per_tile = clamp(ticks_per_tile - 5, 5, 20)
		start_coords += Vector2i(1,0)
		
		if instructions.action_plan.size() >= 10:
			push_error("action_plan size has exceeded the maximum possible limit for Rocket and is still building.\n Check Flight Plan: \t " + JSON.stringify(instructions.action_plan))
			break
	
	var last_step = TickInstruction.new(
			tick_accumulator,
			1,
			"projectile",
			new_projectile_id,
			TickInstruction.action_types.FIZZLE,
			{}
		)
	instructions.action_plan.push_back(last_step)
	
	return instructions


#NOTE: Not necessary yet. This would be for something like a redirect. 
#started accidentally while trying to workout collisions
func _generate_revised_action_plan(projectile_id: String, _LocalAuthority: Node) -> Dictionary:
	var projectile: ProjectileController = MatchSettings.BRIDGE.get_projectile_by_id(projectile_id)
	projectile.current_revision += 1
	var _new_revision = projectile.current_revision
	#var new_instructions = _new_instructions(projectile.projectile_id, projectile.ability_id, projectile.projectile_id)
	
	return {}


func cast(instructions: Dictionary) -> void:
	var caster: Character = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	#Finish cast animation
	#add ProjectileController to projectiles in ARENA
	#instantiate ROCKET and add it to the ProjectileController
	var new_rocket = ROCKET.instantiate()
	var new_controller: ProjectileController = CONTROLLER.new(new_rocket)
	new_controller.projectile_id = instructions.projectile_id
	new_controller.current_revision = instructions.revision
	new_controller.grid_coords = caster.grid_coords
	#instructions may include: action_plan, start_coords, caster, team, direction
	
	MatchSettings.BRIDGE.mount_new_projectile(new_controller)
	MatchSettings.BRIDGE.load_tick_instructions(instructions.action_plan)
	
	##OLD_INSTRUCTIONS
	#var caster = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	#new_rocket.team = caster.team
	#new_rocket.position = instructions.vectors.start_pos
	#new_rocket.travel_direction = caster.attack_direction #handled by authority
	
	#new_rocket.connect("update_tile_position", MatchSettings.BRIDGE.bind_projectile_move(new_rocket)) #this will be handled by authority
	#MatchSettings.BRIDGE.connect_signal_to_arena(new_rocket, "attempt_damage", "_attempt_damage")
	#MatchSettings.BRIDGE.add_child_to_arena(new_rocket)
	#TODO: use ActorFactory spawn_projectile?
	#TODO: Projectile for movement?
