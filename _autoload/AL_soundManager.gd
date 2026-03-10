extends Node

var active_sounds := []
var AUDIO_STREAM_LIMIT := 5

func play_audio_stream(audio_info: SoundResource) -> void:
	
	if get_children().size() < AUDIO_STREAM_LIMIT:
		var stream_player = AudioStreamPlayer.new()
		stream_player.stream = audio_info.sound
		stream_player.volume_db = audio_info.volume
		stream_player.pitch_scale = audio_info.pitch_scale
		stream_player.connect("finished", stream_player.queue_free)
		
		active_sounds.push_back(stream_player)
		add_child(stream_player)
		stream_player.play()
