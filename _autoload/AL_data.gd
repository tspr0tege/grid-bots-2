extends Node

enum CGs { NEUTRAL, UNIVERSAL, TEAM_1, TEAM_2 } #Control Groups
enum roles { PLAYER_CHARACTER, OPPOSING_PLAYER, NPCs }
enum matchmaking_steps { HANDSHAKE, COMBAT_DATA }

var multiplayer_id = null
#var opponent_id = null
var player_control_group : CGs
var match_settings := {}

var ability_deck = {}


func _ready() -> void:
	init_match_settings()


func init_match_settings() -> void:
	multiplayer_id = null
	player_control_group = CGs.TEAM_1
	
	match_settings = {
		#TODO: Add multiplayer_id, opponent_id, and is_online_match
		#Requires changes to SceneManager and MatchController
		"handshake": {
			"player": {
				"ready": false,
			},
			"opponent": {
				"ready": false,
			},
		},
		"combat_data": {
			"player": {
				"ready": false,
			},
			"opponent": {
				"ready": false,
			},
		},
		"characters": [
			{
				"model": "res://entities/test-character/player_character.tscn",
				"role": roles.PLAYER_CHARACTER,
				"coords": Vector2i(1,1),
				"control_group": player_control_group,
			},
		],
	}


func ready_check(ready_step: String) -> bool:
	return match_settings[ready_step].player.ready && match_settings[ready_step].opponent.ready


func opposing_group(control_group) -> CGs:
	if control_group == CGs.TEAM_1: return CGs.TEAM_2
	else: return CGs.TEAM_1
