extends Node

var card_hand := [
	"ROCK_CUBE",
	"PUNCH",
	"CAPTURE_TILE"
]

func _handle_pause_button() -> void:
	if get_tree().paused:
		#print("Unpaused")
		%PauseMenu.visible = false
		get_tree().paused = false
	else:
		#print("Paused")
		get_tree().paused = true
		%PauseMenu.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.load_menu()


func _UI_input_fire_button_pressed() -> void:
	%CombatArena._attempt_attack(%CombatArena.player_character)


func _UI_input_use_ability(index: int) -> void:
	if index < card_hand.size():
		%CombatArena._attempt_ability(%CombatArena.player_character, card_hand[index])
	else:
		print("index %s received, but not yet accounted for." % index)
