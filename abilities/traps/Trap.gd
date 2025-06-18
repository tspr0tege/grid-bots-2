class_name Trap extends Node

func trigger_trap(trigger_cause: Character) -> void:
	print("Trap triggered by %s without a custom trigger_trap function." % trigger_cause)
