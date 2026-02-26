class_name Ability extends Node

@export var COST: int
@export var ICON: CompressedTexture2D
@export var UID := "BLANK"


func validate(_caster_id : String, _amx : AbilityMethodsExport) -> Dictionary:
	print("Ability %s does not yet have a custom validate_ability function.")
	
	return {}


func cast(_amx : AbilityMethodsExport, _instructions: Dictionary) -> void:
	pass
