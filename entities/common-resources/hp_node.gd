extends Node

signal received_damage(attempted_amount: float)
signal HP_changed(new_amt: float)
signal character_died

@export var MAX_HP: float = 100
@export var animation_player: AnimationPlayer
@export var hit_sfx: AudioStreamPlayer
@export_range(0.0, 1.0) var defense: float = 0.0

var is_shielded: bool = false
var shield_effect: Callable

var HP: float

func _ready() -> void:
	HP = MAX_HP

func take_damage(amt: float) -> void:
	var net_damage = amt * (1.0 - defense)
	HP -= net_damage
	HP = max(HP, 0)
	if animation_player: animation_player.play("white_flash")
	if net_damage > 0: emit_signal("HP_changed", HP)
	if HP > 0:
		if hit_sfx: hit_sfx.play()
		emit_signal("received_damage", amt)
	else:
		emit_signal("character_died")


func take_healing(amt: float) -> void:
	HP += amt
	emit_signal("HP_changed", HP)


func connect_shield(shield_program: Callable) -> void:
	is_shielded = true
	shield_effect = shield_program


func affect_defense(amt: float, time: float) -> void:
	var current_def = defense
	get_tree().create_timer(time).timeout.connect(revert_defense.bind(current_def))
	
	defense += amt


func revert_defense(prev_level: float) -> void:
	defense = prev_level
