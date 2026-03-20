extends Control


func _ready() -> void:
	$TabContainer.current_tab = 0
	SceneManager.online_client.join_matchmaking_queue()


func update_tab(_tab_content: Dictionary) -> void:
	$TabContainer.current_tab += 1
