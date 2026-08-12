extends Node


	if SceneManager.in_online_match:
		connect("transmit_ability", SceneManager.online_client.transmit_ability_input)
		connect("transmit_move", SceneManager.online_client.transmit_move_input)
