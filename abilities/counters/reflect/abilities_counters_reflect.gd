extends Ability

const REFLECT = preload("res://abilities/counters/reflect/object_reflect.tscn")
const PEW = preload("res://abilities/instant-shot/test-shot/abilities_instant-shot_test-shot.tscn")

var caster_hp_node
var shield_object: Node3D


func validate(caster: Character, _arena: Node3D) -> Dictionary:
	instructions.ability_id = UID
	instructions.target_type = "OCCUPANT"
	instructions.vectors = {"target_coords": caster.grid_pos}
	instructions.can_cast = true
	
	return instructions


func cast(arena: Node3D, final_instructions: Dictionary) -> void:
	var caster = final_instructions.target
	var new_shield = REFLECT.instantiate()
	shield_object = new_shield
	new_shield.get_node("Timer").connect("timeout", _remove_shield)
	caster.add_child(new_shield)
	
	caster_hp_node = caster.get_node("HpNode")
	caster_hp_node.connect_shield(_reflect_damage.bind(caster, arena))


func _remove_shield() -> void:
	caster_hp_node.is_shielded = false
	shield_object.queue_free()


func _reflect_damage(attempted_dmg: float, caster: Character, arena: Node3D) -> float:
	var new_pew = PEW.instantiate()
	new_pew.dmg = attempted_dmg	
	arena._attempt_ability(caster, new_pew)
	#new_pew.use_ability(caster, arena)
	_remove_shield()
	return 0.0
