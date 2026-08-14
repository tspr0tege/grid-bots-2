extends Node

## PERSISTENT
enum teams { NEUTRAL, UNIVERSAL, TEAM_1, TEAM_2 }
enum roles { PLAYER_CHARACTER, OPPOSING_PLAYER, NPCs }

var player_energy_accum_rate := 0.5
var player_max_energy := 20.0
var player_deck := [ # array of ids
	"pro-rkt-l1",
	"smn-cub-r1",
	"thw-cnb-b1",
]
var player_bot_config := {
	"model": "res://entities/test-character/player_character.tscn",
	"start_coords": Vector2i(1,1),
}


## PER MATCH
var character_lineup := []
var is_online_match := false
var multiplayer_id = null
var player_character_id
var player_team : teams
var ability_list := {} #All abilities in match
var match_deck := []
var player_hand := []
var player_energy := 1.0


func _propagate_ability_list() -> void:
	#iterate through player deck - including cascade effects (like push)
	#do the same for opposing player deck
	#each ability is keyed by id and needs to be called with load()
	pass


func init_match_settings() -> void:
	character_lineup = []
	is_online_match = false
	multiplayer_id = null
	player_character_id = null
	player_team = teams.NEUTRAL
	ability_list = {}
	match_deck = []
	player_hand = []
	player_energy = 1.0


func discard(card_in_hand: int) -> void:
	match_deck.push_back(player_hand[card_in_hand])


func draw_card(hand_index: int) -> String:
	var new_card = match_deck.pop_front()
	player_hand[hand_index] = new_card
	return new_card


func shuffle_and_draw() -> void:
	match_deck = player_deck.duplicate()
	match_deck.shuffle()
	
	var hand_size = clamp(player_deck.size(), 0, 5)
	player_hand.resize(hand_size)
	for n in range(hand_size):
		draw_card(n)


func opposing_team(team: teams) -> teams:
	if team == teams.TEAM_1: return teams.TEAM_2
	else: return teams.TEAM_1
