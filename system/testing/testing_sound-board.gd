extends Control

@export var SOUND_1: SoundResource
@export var SOUND_2: SoundResource
@export var SOUND_3: SoundResource
@export var SOUND_4: SoundResource

func handle_soundboard_input(var_name: String) -> void:
	#print(self[var_name])
	SoundManager.play_audio_stream(self[var_name])
