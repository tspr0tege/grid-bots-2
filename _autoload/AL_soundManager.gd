extends Node

var active_sounds := []
var AUDIO_STREAM_LIMIT := 5

var BGM_JUKEBOX := AudioStreamPlayer.new()
const COOL_DANCH = preload("res://Cool Danch Network is Spreading.mp3")
const RHODES = preload("res://scenes/main-menu/rhodes.mp3")
const GLORYTOTHEMACHINE = preload("res://scenes/main-menu/escape_-_glorytothemachine.mp3")

const BATTLE_MEGA_WALL = preload("res://scenes/battle-scene/music/awake10_megaWall.mp3")
const DARKER_WAVES = preload("res://scenes/battle-scene/music/Zander Noriega - Darker Waves.mp3")
const N_DIMENSIONS = preload("res://scenes/battle-scene/music/n-Dimensions (Main Theme).mp3")
const RED_DOORS = preload("res://scenes/battle-scene/music/Red Doors 2.0 (GameClosure Edition).mp3")
const THRUST_SEQUENCE = preload("res://scenes/battle-scene/music/Thrust Sequence.mp3")

const BATTLE_TRACKS := [
	BATTLE_MEGA_WALL,
	DARKER_WAVES,
	N_DIMENSIONS,
	RED_DOORS,
	THRUST_SEQUENCE
]

func _ready() -> void:
	BGM_JUKEBOX.bus = "Music"
	#BGM_JUKEBOX.
	add_child(BGM_JUKEBOX)

func play_audio_stream(audio_info: SoundResource) -> void:
	
	if get_children().size() < AUDIO_STREAM_LIMIT:
		var stream_player = AudioStreamPlayer.new()
		stream_player.bus = "SFX"
		stream_player.stream = audio_info.sound
		stream_player.volume_db = audio_info.volume
		stream_player.pitch_scale = audio_info.pitch_scale
		stream_player.connect("finished", stream_player.queue_free)
		
		active_sounds.push_back(stream_player)
		add_child(stream_player)
		stream_player.play()


func play_bgm_stream(track_name: String) -> void:
	match track_name:
		"MENU":
			BGM_JUKEBOX.stream = GLORYTOTHEMACHINE
			BGM_JUKEBOX.volume_db = -4.0
		"BATTLE":
			BGM_JUKEBOX.stream = BATTLE_TRACKS[randi_range(0, BATTLE_TRACKS.size() - 1)]
			BGM_JUKEBOX.volume_db = -8.0
		_:
			push_warning("Track name %s is unrecognized" % track_name)
	
	if !BGM_JUKEBOX.playing:
		BGM_JUKEBOX.play()
