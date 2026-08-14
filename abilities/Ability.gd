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
@export var ability_behavior : Dictionary #NOTE: ability_behavior will be temporarily housed in MethodsRegister
@export var methods : AbilityMethodsRegister
#Properties: Elemental, etc



func can_cast(caster_id : String, amx : AbilityMethodsExport) -> bool:
	#push_error("Ability %s does not have a can_cast validation function." % ABILITY_DATA.ability_name)
	if (caster_id == MatchData.player_character_id and 
	amx.get_current_energy_level() < energy_cost):
		return false 
	
	return true
