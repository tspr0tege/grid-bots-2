extends PanelContainer

@onready var clock_offset: Label = $VBoxContainer/ClockOffset
@onready var ping: Label = $VBoxContainer/Ping

func _process(delta: float) -> void:
	var offset_value = SceneManager.online_client.estimated_server_clock_difference
	var ping_number = SceneManager.online_client.latest_ping_avg
	clock_offset.text = "Clock offset: %s ms" % offset_value
	ping.text = "PING: %s ms" % ping_number
