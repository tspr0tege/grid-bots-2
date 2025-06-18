class_name Ability extends Node

@export var COST: int
@export var ICON: CompressedTexture2D

func use_ability(caster : Character, arena : Node3D) -> bool:	
	print("A card has been played from the default use_ability method. Please create a custom method for " + str(self.name))
	return false
