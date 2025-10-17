class_name Ability extends Node

@export var COST: int
@export var ICON: CompressedTexture2D
@export var UID := "BLANK"

var instructions := {
		"action": "ABILITY",
		#"ability_id": UID,
		"opponent_id": Data.opponent_id,
		"can_cast": true,
	}


func use_ability(_caster : Character, _arena : Node3D) -> bool:	
	print("A card has been played from the default use_ability method. Please create a custom method for " + str(self.name))
	return false


func validate(_caster: Character, _arena: Node3D) -> Dictionary:
	print("Ability %s does not yet have a custom validate_ability function.")
	
	return {}


func cast(_arena: Node3D, _instructions: Dictionary) -> void:
	pass
