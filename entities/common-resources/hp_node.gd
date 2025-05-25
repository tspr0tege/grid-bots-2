extends Node

signal HP_changed(new_amt: float)

@export var HP: float = 100
@export var animation_player: AnimationPlayer
@export var hit_sfx: AudioStreamPlayer

func _ready() -> void:
	emit_signal("HP_changed", HP)
	

func take_damage(amt: float) -> void:
	HP -= amt
	if animation_player: animation_player.play("white_flash")
	if hit_sfx: hit_sfx.play()
	
	emit_signal("HP_changed", HP)
	

func take_healing(amt: float) -> void:
	HP += amt
	emit_signal("HP_changed", HP)
	
