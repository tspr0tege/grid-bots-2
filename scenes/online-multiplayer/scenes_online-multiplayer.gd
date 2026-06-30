extends Control

@onready var header: Label = $StatusContainer/VBoxContainer/Header
@onready var details_text: RichTextLabel = $StatusContainer/VBoxContainer/Details/RichTextLabel


func _ready() -> void:
	$TabContainer.current_tab = 0
	SceneManager.online_client.join_matchmaking_queue()


func update_tab(_tab_content: Dictionary) -> void:
	
	$TabContainer.current_tab += 1


func handle_matchmaker_update(step: int, data: Dictionary = {}) -> void:
	match step:
		Data.matchmaking_steps.HANDSHAKE:
			header.text = "Opponent found, exchanging handshake."
		Data.matchmaking_steps.COMBAT_DATA:
			header.text = "Exchanging combat readiness data."
	
	for key in data.keys():
		details_text.text += "%s: %s \n" % [str(key), JSON.stringify(data[key])]
	
	details_text.text += "\n \n"
