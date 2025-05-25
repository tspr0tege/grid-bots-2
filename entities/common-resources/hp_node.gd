extends Node

signal HP_changed(new_amt: float)
signal character_died

@export var HP: float = 100
@export var animation_player: AnimationPlayer
@export var hit_sfx: AudioStreamPlayer


func take_damage(amt: float) -> void:
	HP -= amt
	if animation_player: animation_player.play("white_flash")
	if hit_sfx: hit_sfx.play()
	if HP <= 0: HP = 0	
	emit_signal("HP_changed", HP)
	if HP == 0: emit_signal("character_died")
	

func take_healing(amt: float) -> void:
	HP += amt
	emit_signal("HP_changed", HP)
	
