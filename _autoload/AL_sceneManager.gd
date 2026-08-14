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
	MatchData.character_lineup = [
		{
			"model": "res://entities/test-character/player_character.tscn",
			#"role": Data.roles.PLAYER_CHARACTER,
			"coords": Vector2i(1,1),
			"control_group": MatchData.teams.TEAM_1,
		},
		{
			"model": "res://entities/test-character/red_character.tscn",
			#"role": Data.roles.NPCs,
			"coords": Vector2i(4, 1),
			"control_group": MatchData.teams.TEAM_2,
			"connections": {
				"attempt_move": "_attempt_move",
				"search_for_target": "search_for_target",
			},
		}
	]
	MatchData.is_online_match = false
	var scene : PackedScene = load(BATTLE_SCENE)
	get_tree().change_scene_to_packed(scene)


func start_online_match() -> void:
	MatchData.is_online_match = true
	print("Starting online match. Scene should change to BATTLE_SCENE")
	var scene : PackedScene = load(BATTLE_SCENE)
	get_tree().change_scene_to_packed(scene)


func goto_matchmaker() -> void:
	var scene : PackedScene = load(CONNECTING_TO_MATCH)
	get_tree().change_scene_to_packed(scene)


func load_menu() -> void:
	MatchData.is_online_match = false
	MatchData.init_match_settings()
	var scene : PackedScene = load(MENU_SCENE)
	get_tree().change_scene_to_packed(scene)
