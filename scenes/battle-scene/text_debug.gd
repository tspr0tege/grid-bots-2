extends PanelContainer

@onready var msg_input: TextEdit = $TextEdit
@onready var msg_output: RichTextLabel = $RichTextLabel


func _ready() -> void:
	SceneManager.online_client.connect("temp_text_901", _handle_temp_text_901)


func _on_button_pressed() -> void:
	var text := msg_input.text

	if text.is_empty():
		return

	if SceneManager.online_client == null:
		msg_output.append_text("No active match.\n")
		return

	var payload := JSON.stringify({
		"text": text
	})

	var result: NakamaAsyncResult = await SceneManager.online_client.socket.send_match_state_async(
		SceneManager.online_client.online_match.match_id,
		Opcodes.SEND_TEXT,
		payload
	)

	if result.is_exception():
		msg_output.append_text("Send failed.\n")
		return

	msg_input.clear()

func _handle_temp_text_901(data) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		msg_output.append_text("Invalid server response.\n")
		return

	if data.get("server_confirmed", false) != true:
		msg_output.append_text("Response was not confirmed.\n")
		return

	var sender_id := str(data.get("sender_user_id", "unknown"))
	var text := str(data.get("text", ""))

	msg_output.append_text("%s: %s\n" % [sender_id, text])
