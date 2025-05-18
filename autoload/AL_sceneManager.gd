extends Node

var player_id: String = ""
var match_result: String = "" # "win", "lose", "draw"

# For future multiplayer use
var is_online_match: bool = false
var match_id: String = ""

# Paths to your main scenes
const MENU_SCENE := "res://scenes/main-menu/main_menu.tscn"
const BATTLE_SCENE := "res://scenes/battle-scene/battle_scene.tscn"
#const WIN_SCENE := "res://scenes/WinScreen.tscn"
#const LOSE_SCENE := "res://scenes/LoseScreen.tscn"

#func _ready():
	#_change_scene(MENU_SCENE)

func start_local_match() -> void:
	is_online_match = false
	match_id = ""
	_change_scene(BATTLE_SCENE)
	

func load_menu() -> void:
	_change_scene(MENU_SCENE)

#func end_match(result: String):
	#match_result = result
	#match_id = ""
#
	#match result:
		#"win":
			#_change_scene(WIN_SCENE)
		#"lose":
			#_change_scene(LOSE_SCENE)
		#"draw":
			#_change_scene(MENU_SCENE) # Handle differently if needed
		#_:
			#push_error("Invalid match result: %s" % result)

func _change_scene(path: String):
	var scene = load(path)
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		push_error("Scene not found: %s" % path)
