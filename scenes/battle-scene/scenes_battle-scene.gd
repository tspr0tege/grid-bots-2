extends Node

@export var ARENA : Node3D

#UI Elements
@onready var abilities_panel = $CanvasLayer/GridContainer/AbilityPanel/VBoxContainer
@onready var ability_buttons = abilities_panel.get_children()
@onready var energy_bar: ProgressBar = $CanvasLayer/GridContainer/EnergyBar/HBoxContainer/TextureProgressBar
@onready var energy_count: Label = $CanvasLayer/GridContainer/EnergyBar/HBoxContainer/Label
const ready_frame = preload("res://abilities/icon frame 128 x 128.png")


func _ready() -> void:
	get_tree().paused = true
	if MatchSettings.is_online_match:
		$CanvasLayer/MatchStartCountdown.match_start_time = SceneManager.online_client.match_start_time_ms
	else:
		$CanvasLayer/MatchStartCountdown.match_start_time = Time.get_ticks_msec() + 4000
	
	SoundManager.play_bgm_stream("BATTLE")
	MatchSettings.shuffle_and_draw()
	for n in range(MatchSettings.player_hand.size()):
		_update_ability_UI_button(n)


func _update_ability_UI_button(index: int) -> void:
	var ability : Ability = MatchSettings.ability_list[MatchSettings.player_hand[index]]
	var button = abilities_panel.get_child(index).get_node("TextureProgressBar")
	button.texture_under = ability.ability_icon
	button.texture_progress = ability.ability_icon
	button.texture_over = null
	button.max_value = ability.energy_cost
	button.value = MatchSettings.player_energy


func _UI_input_fire_button_pressed() -> void:
#TODO: FIX THIS FUNCTION
	var player_character = $MatchController.characters[MatchSettings.player_character_id]
	player_character.use_base_attack()


func _UI_input_use_ability(index: int) -> void:
	#not enough energy
	var ability_id = MatchSettings.player_hand[index]
	print("_UI_input_use_ability:\n index = %s,\n player_hand = %s,\n ability_id = %s" % [index, str(MatchSettings.player_hand), ability_id])
	#var ability : Ability = AbilityLibrary[ability_id]
	#The above is wrong anyway. Abilities need to be pulled from MatchData
	$MatchController.attempt_ability(MatchSettings.player_character_id, ability_id)


func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()


func _on_combat_arena_match_over(player_wins: bool) -> void:
	get_tree().paused = true
	var result = "You Win!" if player_wins else "You Lost!"
	%MatchResult.text = result
	$CanvasLayer/MatchOver.visible = true


func _update_energy() -> void:
	energy_bar.value = MatchSettings.player_energy
	energy_count.text = str(floori(MatchSettings.player_energy))
	var abilities = abilities_panel.get_children()
	for i in range(MatchSettings.player_hand.size()):
		var progress_bar = abilities[i].get_node("TextureProgressBar")
		var ability: Ability = MatchSettings.ability_list[MatchSettings.player_hand[i]]
		progress_bar.value = MatchSettings.player_energy
		if progress_bar.texture_over and MatchSettings.player_energy < ability.energy_cost: 
			progress_bar.texture_over = null
		if !progress_bar.texture_over and MatchSettings.player_energy >= ability.energy_cost:
			progress_bar.texture_over = ready_frame


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


func _on_match_start_countdown_finished() -> void:
	get_tree().paused = false
	$MatchController.tick_counter_active = true
