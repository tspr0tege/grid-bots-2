extends Control

@onready var room_code_display: Label = $HBoxContainer/Create/RoomCodeDisplay
@onready var create_room_button: Button = $HBoxContainer/Create/CreateRoom
@onready var join_code_input: LineEdit = $HBoxContainer/Join/JoinCodeInput
@onready var join_room_button: Button = $HBoxContainer/Join/JoinRoom

signal join_room_with_code(code)
#signal room_code_received(code)
signal generate_invite_code

func _ready() -> void:
	#connect functions to SceneManager signals
	SceneManager.connect("room_code_received", display_new_room_code)
	connect("generate_invite_code", SceneManager.get_new_room_code)
	connect("join_room_with_code", SceneManager.handle_join_room_with_code)


func _on_cancel_pressed() -> void:
	SceneManager.load_menu()


func _on_create_room_pressed() -> void:
	print("Create room pressed. Emitting generate_invite_code signal")
	generate_invite_code.emit()


func display_new_room_code(code) -> void:
	#TODO: Disable button?
	room_code_display.text = str(code)


func _on_join_code_changed(new_text: String) -> void:
	join_room_button.disabled = new_text.length() != 4


func _on_join_room_pressed() -> void:
	join_room_with_code.emit(join_code_input.text)


func _on_join_code_submitted(new_text: String) -> void:
	join_room_button.emit("pressed")
