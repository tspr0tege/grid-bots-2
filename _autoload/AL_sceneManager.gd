extends Node

enum match_result {win, lose, draw}

var online_client = null

const MENU_SCENE := "res://scenes/main-menu/main_menu.tscn"
const BATTLE_SCENE := "res://scenes/battle-scene/battle_scene.tscn"
const CONNECTING_TO_MATCH = "res://scenes/connecting-to-match/connecting_to_match.tscn"

const NAKAMA_CLIENT := preload("res://system/nakama_client.tscn")

const PLAYER_CHARACTER = preload("res://entities/test-character/player_character.tscn")
const RED_CHARACTER = preload("res://entities/test-character/red_character.tscn")


func _ready() -> void:
	#print("SceneManager _ready function triggered")
	online_client = NAKAMA_CLIENT.instantiate()
	add_child(online_client)


func start_local_match() -> void:
	#MatchSettings.character_lineup = [
		#{
			#"model": "res://entities/test-character/player_character.tscn",
			##"role": Data.roles.PLAYER_CHARACTER,
			#"coords": Vector2i(1,1),
			#"team": MatchSettings.teams.TEAM_1,
		#},
	#]
	#NOTE: Should player_bot_config just be assumed on startup? How to pair with server assigned IDs?
	MatchSettings.character_lineup.push_back(MatchSettings.player_bot_config)
	MatchSettings.character_lineup.push_back(
		{
			"bot_type": "red_test_bot",
			"role": MatchSettings.roles.NPCs,
			"start_coords": Vector2i(4, 1),
			"team": MatchSettings.teams.TEAM_2,
			"connections": {
				"attempt_move": "request_move",
				"search_for_target": "search_for_target",
			},
		}
	)
	MatchSettings.is_online_match = false
	var scene : PackedScene = load(BATTLE_SCENE)
	get_tree().change_scene_to_packed(scene)


func start_online_match() -> void:
	MatchSettings.is_online_match = true
	print("Starting online match. Scene should change to BATTLE_SCENE")
	var scene : PackedScene = load(BATTLE_SCENE)
	get_tree().change_scene_to_packed(scene)


func goto_matchmaker() -> void:
	var scene : PackedScene = load(CONNECTING_TO_MATCH)
	get_tree().change_scene_to_packed(scene)


func load_menu() -> void:
	MatchSettings.is_online_match = false
	MatchSettings.init_match_settings()
	var scene : PackedScene = load(MENU_SCENE)
	get_tree().change_scene_to_packed(scene)
