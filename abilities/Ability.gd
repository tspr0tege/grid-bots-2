class_name Ability
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
@export var ability_icon: CompressedTexture2D
@export var energy_cost : int = 1
@export var upgrade_to_id : String
#@export var ability_behavior : Dictionary #NOTE: ability_behavior will be temporarily housed in MethodsRegister. 
#NOTE: ability_behavior may be unecessary on the client. 
@export var methods : AbilityMethodsRegister
@export var chain_abilities : Array = []
#Properties: Elemental, etc
