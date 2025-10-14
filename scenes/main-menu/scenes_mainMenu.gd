extends Control



func _handle_button_input(button_name: String) -> void:
	match button_name:
		"START":
			#print("Start game")
			SceneManager.start_local_match()
		"ONLINE":
			SceneManager.goto_multiplayer()
		"QUIT":
			#print("Close program")
			get_tree().quit()
	
