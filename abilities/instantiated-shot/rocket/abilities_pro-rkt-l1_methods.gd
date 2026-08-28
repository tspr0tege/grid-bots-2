## ROCKET
class_name pro_rkt_l1_methods
extends AbilityMethodsRegister

@export var test_variable := false

const ROCKET = preload("res://abilities/instantiated-shot/rocket/pro-rkt-l1_model.tscn")
const CONTROLLER = preload("res://abilities/instantiated-shot/rocket/abilities_pro-rkt-l1_controller.gd")

func generate_local_instructions(caster_id: String, LocalAuthority: Node) -> Dictionary:
	var caster: Character = MatchSettings.BRIDGE.get_character_by_id(caster_id)
	var instructions = {
		"caster_id": caster_id,
		"ability_id": "pro-rkt-l1",
		"projectile_id": LocalAuthority.generate_character_id(),
		"start_coords": caster.grid_coords,
		"flight_plan": [], #flight_plan will be a series of TickInstructions
	}
	
	#setup travel by tick count (at tick n, speed in position/tick, as a function of the width of a tile.
	
	
	return instructions


func cast(instructions: Dictionary) -> void:
	#Finish cast animation
	#add ProjectileController to projectiles in ARENA
	#instantiate ROCKET and add it to the ProjectileController
	var new_rocket = ROCKET.instantiate()
	var new_controller: ProjectileController = CONTROLLER.new(new_rocket)
	new_controller.projectile_id = instructions.projectile_id
	#instructions may include: flight_plan, start_coords, caster, team, direction
	
	
	##OLD_INSTRUCTIONS
	#var caster = MatchSettings.BRIDGE.get_character_by_id(instructions.caster_id)
	#new_rocket.team = caster.team
	#new_rocket.position = instructions.vectors.start_pos
	#new_rocket.travel_direction = caster.attack_direction #handled by authority
	
	#new_rocket.connect("update_tile_position", MatchSettings.BRIDGE.bind_projectile_move(new_rocket)) #this will be handled by authority
	#MatchSettings.BRIDGE.connect_signal_to_arena(new_rocket, "attempt_damage", "_attempt_damage")
	#MatchSettings.BRIDGE.add_child_to_arena(new_rocket)
	#TODO: use ActorFactory spawn_projectile.
	#TODO: Projectile for movement?
