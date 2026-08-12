class_name AbilityDatabaseEntry
extends Resource

enum AbilityCategory {
	BUFF,
	COUNTER,
	DEBUFF,
	INSTANT_SHOT,
	MELEE,
	PROJECTILE,
	STAGE_EFFECT,
	SUMMON,
	THROWN,
	TRAP
}

@export var ability_id : String
@export var ability_name : String
@export var ability_category : AbilityCategory
@export var energy_cost : int = 1
@export var upgrade_to_id : String
@export var ability_behavior : Dictionary
#Properties: Elemental, etc

#Possible behavior JSON entries:
	#{
		#speed (ticks per tile)
		#direction Vector2()
	#Projectile specific:
		#in_strike_zone, collision_check_active, or can_damage? (not sure on wording yet)
		#cascade_effects (next ability call, or instantiated copy)
		#on_collision = what to do when projectile collides with character
		#travel_behavior (linear, diagonal, bounce, etc - matched up with server functions)
		#travel_props - parameters to pass into travel behavior function
		#can_penetrate - bool
		#penetration_limit - int
		#friendly_fire - bool (quit hittin' yer'self)
	#}
