extends Control

@onready var title: Label = $PanelContainer/VBoxContainer/Title
@onready var message_content: RichTextLabel = $PanelContainer/VBoxContainer/MessageContent


func _ready() -> void:
	SceneManager.online_client.connect("match_connect_msg", handle_match_connect_msg)
	SceneManager.online_client.connect("match_making_phase", handle_match_making_phase)
	title.text = "Searching for a match..."
	message_content.text = ""
	SceneManager.online_client.join_matchmaking_queue()


func handle_match_connect_msg(msg_content: Dictionary) -> void:
	for key in msg_content:
		message_content.append_text("%s: %s\n \n" % [key, msg_content[key]])

func handle_match_making_phase(phase_title: String) -> void:
	title.text = phase_title
