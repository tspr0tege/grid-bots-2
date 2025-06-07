extends Node

signal received_damage(attempted_amount: float)
signal HP_changed(new_amt: float)
signal character_died

@export var HP: float = 100
@export var animation_player: AnimationPlayer
@export var hit_sfx: AudioStreamPlayer
@export_range(0.0, 1.0) var defense: float = 0.0


func take_damage(amt: float) -> void:
	var received_damage = amt * (1.0 - defense)
	HP -= received_damage
	HP = max(HP, 0)
	if animation_player: animation_player.play("white_flash")
	if received_damage > 0: emit_signal("HP_changed", HP)
	if HP > 0:
		if hit_sfx: hit_sfx.play()
		emit_signal("received_damage", amt)
	else:
		emit_signal("character_died")
	

func take_healing(amt: float) -> void:
	HP += amt
	emit_signal("HP_changed", HP)
	
