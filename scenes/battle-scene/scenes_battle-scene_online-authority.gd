extends Node

@export var ARENA : Arena
@export var MATCH_CONTROLLER : MatchController


func init_match() -> void:
	MATCH_CONTROLLER.connect("transmit_ability", SceneManager.online_client.transmit_ability_input)
	MATCH_CONTROLLER.connect("transmit_move", SceneManager.online_client.transmit_move_input)
	SceneManager.online_client.connect("opponent_move", MATCH_CONTROLLER._execute_move)
	SceneManager.online_client.connect("opponent_use_ability", MATCH_CONTROLLER.execute_ability)
