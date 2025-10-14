extends Node

enum CGs { NONE, RED, BLUE, UNIVERSAL } #Control Groups

var multiplayer_id = null
var opponent_id = null

var ability_deck = {}

func opposing_group(character: Character) -> CGs:
	if character.control_group == CGs.RED: return CGs.BLUE
	else: return CGs.RED
