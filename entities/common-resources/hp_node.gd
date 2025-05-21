extends Node

signal HP_changed(new_amt: float)

@export var HP: float = 100

func _ready() -> void:
	emit_signal("HP_changed", HP)
	

func take_damage(amt: float) -> void:
	HP -= amt
	emit_signal("HP_changed", HP)
	

func take_healing(amt: float) -> void:
	HP += amt
	emit_signal("HP_changed", HP)
	
