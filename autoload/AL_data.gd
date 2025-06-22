extends Node

enum CGs { NONE, RED, BLUE, UNIVERSAL } #Control Groups

func opposing_group(character: Character) -> CGs:
	if character.control_group == CGs.RED: return CGs.BLUE
	else: return CGs.RED
