extends Node

enum CGs { NEUTRAL, UNIVERSAL, TEAM_1, TEAM_2 } #Control Groups
enum roles { PLAYER_CHARACTER, OPPOSING_PLAYER, NPCs }

var player_control_group = CGs.TEAM_1
var multiplayer_id = null
#var opponent_id = null

var ability_deck = {}

func opposing_group(control_group) -> CGs:
	if control_group == CGs.TEAM_1: return CGs.TEAM_2
	else: return CGs.TEAM_1
