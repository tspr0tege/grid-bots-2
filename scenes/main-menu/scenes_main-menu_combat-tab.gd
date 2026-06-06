extends Control

@export var sfx_click_03 : SoundResource
@export var sfx_complete_02 : SoundResource
@export var sfx_confirm_02 : SoundResource
@export var sfx_confirm_06 : SoundResource
@export var sfx_ui_change_option_02 : SoundResource

func _handle_button_input(button_name: String) -> void:
	match button_name:
		"START":
			SoundManager.play_audio_stream(sfx_ui_change_option_02)
			SceneManager.start_local_match()
		"ONLINE":
			SoundManager.play_audio_stream(sfx_ui_change_option_02)
			SceneManager.goto_matchmaker()
		"SETTINGS":
			_toggle_settings()
		"QUIT":
			get_tree().quit()


func _toggle_settings() -> void:
	SoundManager.play_audio_stream(sfx_complete_02)
	$Settings.visible = !$Settings.visible
