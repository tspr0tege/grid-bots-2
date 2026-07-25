extends Control

@onready var debug_text: RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel



func _on_button_pressed() -> void:
	var response = await SceneManager.online_client.invoke_gridbots_runtime_hello()
	
	debug_text.text = str(response)
