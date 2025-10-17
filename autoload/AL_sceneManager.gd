extends Node

var player_id: String = ""
var match_result: String = "" # "win", "lose", "draw"

signal request_invite_code
signal room_code_received(code)
signal attempt_join_room(code)

# For future multiplayer use
#var match_id: String = ""
var online_client = null

# Paths to your main scenes
const MENU_SCENE := "res://scenes/main-menu/main_menu.tscn"
const BATTLE_SCENE := "res://scenes/battle-scene/battle_scene.tscn"
const ONLINE_SCENE = "res://scenes/online-multiplayer/online_multiplayer.tscn"

const WEB_SOCKET_CLIENT := preload("res://system/web_socket_client.tscn")
#var scene : PackedScene
const PLAYER_CHARACTER = preload("res://entities/test-character/player_character.tscn")
const RED_CHARACTER = preload("res://entities/test-character/red_character.tscn")

var combatants := []

func load_combatants(arena) -> void:
	for entry in combatants:
		entry.call(arena)


func start_local_match() -> void:
	var scene : PackedScene = load(BATTLE_SCENE)
	online_client = null
	combatants = []
	
	#test player character
	combatants.push_back(func(arena) -> void:
		arena.player_character = PLAYER_CHARACTER.instantiate()
		arena.get_node("%CombatArena").add_child(arena.player_character)
		arena.place_character_on_board(arena.player_character, Vector2i(1, 1))
		)
	
	#test enemy
	combatants.push_back(func(arena) -> void:
		arena.enemy_character = RED_CHARACTER.instantiate()
		arena.get_node("%CombatArena").add_child(arena.enemy_character)	
		arena.enemy_character.connect("attempt_move", arena._attempt_move)
		arena.place_character_on_board(arena.enemy_character, Vector2i(4, 1))
		)
	
	
	get_tree().change_scene_to_packed(scene)


func start_online_match() -> void:
	var scene : PackedScene = load(BATTLE_SCENE)
	combatants = []
	
	combatants.push_back(func(arena) -> void:
		arena.player_character = PLAYER_CHARACTER.instantiate()
		arena.get_node("%CombatArena").add_child(arena.player_character)
		#arena.get_node("%CombatArena").connect("player_input", online_client.send_local_input_to_remote)
		arena.place_character_on_board(arena.player_character, Vector2i(1, 1))
		)
	
	combatants.push_back(func(arena) -> void:
		arena.enemy_character = PLAYER_CHARACTER.instantiate()
		arena.enemy_character.rotation.y = 180
		arena.enemy_character.attack_direction = -1
		arena.enemy_character.control_group = Data.CGs.RED
		arena.get_node("%CombatArena").add_child(arena.enemy_character)
		online_client.connect("opponent_move", func(coords):
			arena._execute_move.call(arena.enemy_character, coords)
			)
		#online_client.connect("opponent_use_ability", func(uid): 
			#arena._attempt_ability.call(arena.enemy_character, Data.ability_deck[uid])
			#)
		arena.place_character_on_board(arena.enemy_character, Vector2i(4, 1))
		)
	
	get_tree().change_scene_to_packed(scene)


func goto_multiplayer() -> void:
	var scene : PackedScene = load(ONLINE_SCENE)
	get_tree().change_scene_to_packed(scene)
	
	online_client = WEB_SOCKET_CLIENT.instantiate()
	get_tree().root.add_child(online_client)
	connect("request_invite_code", online_client.generate_invite_code)
	connect("attempt_join_room", online_client.claim_invite_code)
	
	#online_client.connect("received_new_room_code", scene.display_new_room_code)
	#scene.connect("join_room_with_code", online_client.claim_invite_code)
	#scene.connect("generate_invite_code", online_client.generate_invite_code)
	#signal join_room_with_code(code)
	#signal room_code_received(code)
	#generate_invite_code
	#claim_invite_code(code)


func load_menu() -> void:
	var scene : PackedScene = load(MENU_SCENE)
	get_tree().change_scene_to_packed(scene)


func emit_new_room_code(code) -> void:
	room_code_received.emit(code)

func get_new_room_code() -> void:
	print("New room code signal recieved in SceneManager. Emitting request_invite_code")
	request_invite_code.emit()

func handle_join_room_with_code(code) -> void:
	print("join_room_with_code signal received in SceneManager. Emitting attempt_join_room signal")
	attempt_join_room.emit(code)
