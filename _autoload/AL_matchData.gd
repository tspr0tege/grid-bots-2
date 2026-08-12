extends Node

enum teams { NEUTRAL, UNIVERSAL, TEAM_1, TEAM_2 }

var multiplayer_id = null
var player_team : teams
var settings := {
	"is_online": false,
}

#ALL ABILITIES IN MATCH
#PLAYER'S ABILITY DECK

#FROM DATA:
#
#var ability_deck = {}
#
#func _ready() -> void:
	#init_match_settings()
#
#func init_match_settings() -> void:
	#multiplayer_id = null
	#player_control_group = CGs.TEAM_1
	#
	#match_settings = {}

#func ready_check(ready_step: String) -> bool:
	#return match_settings[ready_step].player.ready && match_settings[ready_step].opponent.ready
#
#
#func opposing_group(control_group) -> CGs:
	#if control_group == CGs.TEAM_1: return CGs.TEAM_2
	#else: return CGs.TEAM_1
