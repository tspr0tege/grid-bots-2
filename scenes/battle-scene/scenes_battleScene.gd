extends Node

@onready var abilities_panel = $CanvasLayer/GridContainer/AbilityPanel/VBoxContainer
@onready var ability_buttons = abilities_panel.get_children()

var next_card := 0
var player_deck := [
	#load().instantiate(),
	load("res://cards/thrown/cannon-ball/card_cannon-ball.tscn").instantiate(),
	load("res://cards/instant-shot/cannon/card-cannon.tscn").instantiate(),
	load("res://cards/traps/landmine/card-landmine.tscn").instantiate(),
	load("res://cards/melee/punch/card-punch.tscn").instantiate(),
	load("res://cards/summons/rock-cube/card-rock_cube.tscn").instantiate(),
	load("res://cards/stage-effects/capture-tile/card-capture_tile.tscn").instantiate(),
	load("res://cards/counters/reflect/card-reflect.tscn").instantiate(),
	load("res://cards/buffs/heal-10/card-heal_10.tscn").instantiate(),
]

var card_hand := []

func _ready() -> void:
	get_tree().paused = false
	card_hand.resize(6)
	for n in range(6):
		draw_card(n)


func draw_card(index: int) -> void:
	#var dealt_card = load(player_deck[next_card]).instantiate()
	var dealt_card = player_deck.pop_at(next_card)
	card_hand[index] = dealt_card
	ability_buttons[index].get_node("TextureRect").texture = dealt_card.ICON
	
	next_card += 1
	if next_card >= player_deck.size(): next_card = 0


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
		player_deck.push_back(card_hand[index])
		draw_card(index)
	else:
		print("index %s received, but not yet accounted for." % index)


func _on_reset_pressed() -> void:	
	get_tree().reload_current_scene()


func _on_combat_arena_match_over(player_wins: bool) -> void:
	get_tree().paused = true
	var result = "You Win!" if player_wins else "You Lost!"
	%MatchResult.text = result
	$CanvasLayer/MatchOver.visible = true
