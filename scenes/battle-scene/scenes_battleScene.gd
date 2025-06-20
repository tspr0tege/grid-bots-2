extends Node

@onready var abilities_panel = $CanvasLayer/GridContainer/AbilityPanel/VBoxContainer
@onready var ability_buttons = abilities_panel.get_children()

var player_deck := [
	#load().instantiate(),
	load("res://abilities/buffs/heal-10/abilities_buffs_heal-10.tscn").instantiate(),
	load("res://abilities/counters/reflect/abilities_counters_reflect.tscn").instantiate(),
	load("res://abilities/debuffs/def-down/abilities_debuffs_def-down.tscn").instantiate(),
	#load("res://abilities/instant-shot/cannon/abilities_instant-shot_cannon.tscn").instantiate(),
	load("res://abilities/instantiated-shot/rocket/abilities_instantiated-shot_rocket.tscn").instantiate(),
	#load("res://abilities/melee/punch/abilties_melee_punch.tscn").instantiate(),
	load("res://abilities/stage-effects/capture-tile/abilities_stage-effects_capture-tile.tscn").instantiate(),
	load("res://abilities/summons/rock-cube/abilities_summons_rock-cube.tscn").instantiate(),
	#load("res://abilities/thrown/cannon-ball/abilities_thrown_cannon-ball.tscn").instantiate(),
	load("res://abilities/traps/landmine/abilities_traps_landmine.tscn").instantiate(),
]

var card_hand := []

func _ready() -> void:
	get_tree().paused = false
	card_hand.resize(6)
	for n in range(6):
		draw_card(n)


func draw_card(index: int) -> void:
	var new_card = player_deck.pop_front()
	card_hand[index] = new_card
	ability_buttons[index].get_node("TextureRect").texture = new_card.ICON


func _handle_pause_button() -> void:
	if get_tree().paused:
		%PauseMenu.visible = false
		get_tree().paused = false
	else:
		get_tree().paused = true
		%PauseMenu.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.load_menu()


func _UI_input_fire_button_pressed() -> void:	
	%CombatArena.player_character.use_base_attack(%CombatArena)


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
