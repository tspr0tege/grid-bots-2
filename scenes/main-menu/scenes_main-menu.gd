extends Control

@export var sfx_confirm_02 : SoundResource

@onready var tabs_container: TabContainer = $TabsContainer
@onready var tab_buttons = $TabsNavigation.get_children()


func _ready() -> void:
	SoundManager.play_bgm_stream("MENU")
	goto_tab(2)


func goto_tab(tab_number: int):
	SoundManager.play_audio_stream(sfx_confirm_02)
	tabs_container.set_current_tab(tab_number)
	
	for tab in tab_buttons:
		var index = int(tab.name.split("")[-1])
		if index <= tab_number and tab.size_flags_horizontal != 0:
			tab.set_h_size_flags(0)
		elif index > tab_number and tab.size_flags_horizontal != 8:
			tab.set_h_size_flags(8)
