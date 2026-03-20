extends Control


func _ready() -> void:
	SoundManager.play_bgm_stream("MENU")


func _handle_button_input(button_name: String) -> void:
	match button_name:
		"START":
			SceneManager.start_local_match()
		"ONLINE":
			SceneManager.goto_matchmaker()
		"SETTINGS":
			_toggle_settings()
		"QUIT":
			get_tree().quit()


func _toggle_settings() -> void:
	$Settings.visible = !$Settings.visible
