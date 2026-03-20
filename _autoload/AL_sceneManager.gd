extends Node

var player_id: String = ""
#var match_result: String = "" # "win", "lose", "draw"
enum match_result {win, lose, draw}

signal request_invite_code
signal room_code_received(code)
signal attempt_join_room(code)

var online_client = null
var match_settings := {}

# Paths to your main scenes
const MENU_SCENE := "res://scenes/main-menu/main_menu.tscn"
const BATTLE_SCENE := "res://scenes/battle-scene/battle_scene.tscn"
const MATCHMAKER_SCENE = "res://scenes/online-multiplayer/online_multiplayer.tscn"

const NAKAMA_CLIENT := preload("res://system/nakama_client.tscn")
#const WEB_SOCKET_CLIENT := preload("res://system/web_socket_client.tscn")

const PLAYER_CHARACTER = preload("res://entities/test-character/player_character.tscn")
const RED_CHARACTER = preload("res://entities/test-character/red_character.tscn")


func _ready() -> void:
	print("SceneManager _ready function triggered")
	online_client = NAKAMA_CLIENT.instantiate()
	add_child(online_client)
	online_client.connect("match_connected", advance_matchmaker_screen)


func start_local_match() -> void:
	var scene : PackedScene = load(BATTLE_SCENE)
	#online_client = null
	match_settings.characters = [
		{
			"model": "res://entities/test-character/player_character.tscn",
			"role": Data.roles.PLAYER_CHARACTER,
			"coords": Vector2i(1,1),
			"control_group": Data.CGs.TEAM_1,
		},
		{
			"model": "res://entities/test-character/red_character.tscn",
			"role": Data.roles.NPCs,
			"coords": Vector2i(4, 1),
			"control_group": Data.CGs.TEAM_2,
			"connections": {
				"attempt_move": "_attempt_move",
				"search_for_target": "search_for_target",
			},
		}
	]
	get_tree().change_scene_to_packed(scene)


func start_online_match() -> void:
	var scene : PackedScene = load(BATTLE_SCENE)
	get_tree().change_scene_to_packed(scene)


func goto_matchmaker() -> void:
	var scene : PackedScene = load(MATCHMAKER_SCENE)
	get_tree().change_scene_to_packed(scene)


func advance_matchmaker_screen(content : Dictionary = {}) -> void:
	get_tree().current_scene.update_tab(content)


func load_menu() -> void:
	var scene : PackedScene = load(MENU_SCENE)
	get_tree().change_scene_to_packed(scene)
