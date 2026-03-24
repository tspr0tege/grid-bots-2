extends Ability

@export var sound : SoundResource

const REFLECT = preload("res://abilities/counters/reflect/object_reflect.tscn")
const PEW = preload("res://abilities/instant-shot/test-shot/abilities_instant-shot_test-shot.tscn")

var caster_hp_node
var shield_object: Node3D


func validate(caster_id : String, amx : AbilityMethodsExport) -> Dictionary:
	var caster = amx.get_character_by_id(caster_id)
	var instructions = {
		"ability_id": UID,
		"caster_id": caster_id,
		"vectors": {"target_coords": caster.grid_coords},
		"can_cast": true,		
	}
	
	return instructions


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var caster = amx.get_character_by_id(instructions.caster_id)
	var new_shield = REFLECT.instantiate()
	shield_object = new_shield
	#$AudioStreamPlayer.play()
	SoundManager.play_audio_stream(sound)
	new_shield.get_node("Timer").connect("timeout", _remove_shield)
	caster.add_child(new_shield)
	
	caster_hp_node = caster.get_node("HpNode")
	caster_hp_node.connect_shield(_reflect_damage.bind(caster, amx.attempt_ability))


func _remove_shield() -> void:
	caster_hp_node.is_shielded = false
	shield_object.queue_free()


func _reflect_damage(attempted_dmg: float, caster: Character, callback: Callable) -> float:
	var new_pew = PEW.instantiate()
	new_pew.dmg = attempted_dmg	
	callback.call(caster, new_pew)
	_remove_shield()
	return 0.0
