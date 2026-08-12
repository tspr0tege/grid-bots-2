class_name Ability
extends RefCounted

@export var ABILITY_DATA : AbilityDatabaseEntry
@export var ICON: CompressedTexture2D

func can_cast(_caster_id : String, _amx : AbilityMethodsExport) -> bool:
	push_error("Ability %s does not have a can_cast validation function." % ABILITY_DATA.ability_name)
	
	return false


func cast(_amx : AbilityMethodsExport, _instructions: Dictionary) -> void:
	push_error("Ability %s does not have a valid cast function." % ABILITY_DATA.ability_name)
	
	pass
