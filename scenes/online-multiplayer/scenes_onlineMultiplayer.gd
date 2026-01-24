extends Control

@onready var nakama_client: Node = $NakamaClient
@onready var client_data: RichTextLabel = $PanelContainer/HBoxContainer/ConnectionOutput/VBoxContainer/ClientData
@onready var session_data: RichTextLabel = $PanelContainer/HBoxContainer/ConnectionOutput/VBoxContainer/SessionData
@onready var socket_data: RichTextLabel = $PanelContainer/HBoxContainer/ConnectionOutput/VBoxContainer/SocketData


func _on_connectionInput_button_pressed() -> void:
	nakama_client.create_online_session()


func _on_nakama_client_update_details() -> void:
	client_data.text = JSON.stringify(nakama_client.client)
	session_data.text = JSON.stringify(nakama_client.session)
	socket_data.text = JSON.stringify(nakama_client.socket)


func _on_socket_button_pressed() -> void:
	nakama_client.create_socket_connection()


func _on_matchmaking_button_pressed() -> void:
	nakama_client.join_matchmaking_queue()
