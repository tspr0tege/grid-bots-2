extends Ability

const REFLECT = preload("res://abilities/counters/reflect/object_reflect.tscn")
const PEW = preload("res://abilities/instant-shot/test-shot/abilities_instant-shot_test-shot.tscn")

var caster_hp_node
var shield_object: Node3D

func use_ability(caster : Character, arena : Node3D) -> bool:
	var new_shield = REFLECT.instantiate()
	shield_object = new_shield
	new_shield.get_node("Timer").connect("timeout", _remove_shield)
	caster.add_child(new_shield)
	
	caster_hp_node = caster.get_node("HpNode")
	caster_hp_node.connect_shield(_reflect_damage.bind(caster, arena))
	
	return true


func _remove_shield() -> void:
	caster_hp_node.is_shielded = false
	shield_object.queue_free()


func _reflect_damage(attempted_dmg: float, caster: Character, arena: Node3D) -> float:
	var new_pew = PEW.instantiate()
	new_pew.dmg = attempted_dmg	
	new_pew.use_ability(caster, arena)
	_remove_shield()
	return 0.0
