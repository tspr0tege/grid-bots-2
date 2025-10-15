extends Node

@onready var abilities_panel = $CanvasLayer/GridContainer/AbilityPanel/VBoxContainer
@onready var ability_buttons = abilities_panel.get_children()
@onready var energy_bar: ProgressBar = $CanvasLayer/GridContainer/EnergyBar/HBoxContainer/TextureProgressBar
@onready var energy_count: Label = $CanvasLayer/GridContainer/EnergyBar/HBoxContainer/Label
const ready_frame = preload("res://abilities/icon frame 128 x 128.png")


var ability_list := [
	#load().instantiate(),
	load("res://abilities/stage-effects/capture-tile/abilities_stage-effects_capture-tile.tscn").instantiate(),
	load("res://abilities/summons/rock-cube/abilities_summons_rock-cube.tscn").instantiate(),
	load("res://abilities/thrown/cannon-ball/abilities_thrown_cannon-ball.tscn").instantiate(),
	load("res://abilities/debuffs/def-down/abilities_debuffs_def-down.tscn").instantiate(),
	load("res://abilities/counters/reflect/abilities_counters_reflect.tscn").instantiate(),
	load("res://abilities/buffs/heal-10/abilities_buffs_heal-10.tscn").instantiate(),
	load("res://abilities/instantiated-shot/rocket/abilities_instantiated-shot_rocket.tscn").instantiate(),
	load("res://abilities/instant-shot/cannon/abilities_instant-shot_cannon.tscn").instantiate(),
	load("res://abilities/melee/punch/abilties_melee_punch.tscn").instantiate(),
	load("res://abilities/traps/landmine/abilities_traps_landmine.tscn").instantiate(),
]
var player_deck = []

var card_hand := []

func _ready() -> void:
	get_tree().paused = false
	
	for ability in ability_list:
		Data.ability_deck[ability.UID] = ability
		player_deck.push_back(ability.UID)
	
	
	card_hand.resize(6)
	for n in range(6):
		draw_card(n)


func draw_card(index: int) -> void:
	var new_card = player_deck.pop_front()
	card_hand[index] = new_card
	#ability_buttons[index].get_node("TextureRect").texture = new_card.ICON
	var button = abilities_panel.get_child(index).get_node("TextureProgressBar")
	button.texture_under = Data.ability_deck[new_card].ICON
	button.texture_progress = Data.ability_deck[new_card].ICON
	button.texture_over = null
	button.max_value = Data.ability_deck[new_card].COST
	button.value = %CombatArena.player_energy


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
	if %CombatArena.player_energy < Data.ability_deck[card_hand[index]].COST: return
	
	if %CombatArena._attempt_ability(%CombatArena.player_character, Data.ability_deck[card_hand[index]]):
		%CombatArena.player_energy -= Data.ability_deck[card_hand[index]].COST
		player_deck.push_back(card_hand[index])
		draw_card(index)


func _on_reset_pressed() -> void:	
	get_tree().reload_current_scene()


func _on_combat_arena_match_over(player_wins: bool) -> void:
	get_tree().paused = true
	var result = "You Win!" if player_wins else "You Lost!"
	%MatchResult.text = result
	$CanvasLayer/MatchOver.visible = true

func _update_energy(value: float) -> void:
	energy_bar.value = value
	energy_count.text = str(floori(value))
	var abilities = abilities_panel.get_children()
	for i in range(6):
		var progress_bar = abilities[i].get_node("TextureProgressBar")
		progress_bar.value = value
		if progress_bar.texture_over and value < Data.ability_deck[card_hand[i]].COST: 
			progress_bar.texture_over = null
		if !progress_bar.texture_over and value >= Data.ability_deck[card_hand[i]].COST:
			progress_bar.texture_over = ready_frame
