extends HSlider

@export var bus_name : String
var sfx_click_03 := SoundResource.new()

var bus_index : int


func _ready() -> void:
	sfx_click_03.sound = load("res://scenes/main-menu/sfx/Click_03.wav")
	sfx_click_03.volume = -10.0
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _on_value_changed(new_value: float) -> void:
	SoundManager.play_audio_stream(sfx_click_03)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
