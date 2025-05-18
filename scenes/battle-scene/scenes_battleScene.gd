extends Node

func _handle_pause_button() -> void:
	if get_tree().paused:
		#print("Unpaused")
		%PauseMenu.visible = false
		get_tree().paused = false
	else:
		#print("Paused")
		get_tree().paused = true
		%PauseMenu.visible = true
	

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.load_menu()
	
