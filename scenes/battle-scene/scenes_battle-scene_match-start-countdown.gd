extends PanelContainer

signal match_start_time_reached

@onready var label: Label = $Label

@export var match_start_time : int

func _process(_delta: float) -> void:
	if match_start_time == null: return
	
	var remaining_ms := match_start_time - Time.get_ticks_msec()
	
	label.text = str(max(remaining_ms / 1000, 0)) # +1?

	if remaining_ms <= 0: 
		match_start_time_reached.emit()
		queue_free()
