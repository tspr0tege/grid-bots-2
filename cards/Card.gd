class_name Card extends Node

@export var COST: int
@export var ICON: CompressedTexture2D

func play_card(caster : Character, arena : Node3D) -> void:
	print("A card has been played from the default play_card method. Please create a custom method for " + str(self.name))
