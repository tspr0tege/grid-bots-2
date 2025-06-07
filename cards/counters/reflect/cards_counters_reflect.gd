extends Node3D

var arena: Node3D
var caster: Character
var caster_current_defense: float = 0.0


func _ready() -> void:
	caster_current_defense = caster.get_node("HpNode").defense
	caster.get_node("HpNode").defense = 1.0


func _reflect_damage(dmg_amt: float) -> void:
	print("Reflecting damage of: " + str(dmg_amt))
	arena._attempt_attack(caster)
	remove_self()


func remove_self() -> void:
	caster.get_node("HpNode").defense = caster_current_defense
	queue_free()
