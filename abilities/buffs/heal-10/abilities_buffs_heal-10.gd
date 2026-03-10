extends Ability

@export var sound : SoundResource

const HEAL_10 = preload("res://abilities/buffs/heal-10/object_heal-10.tscn")
const heal_amt = 10
#var instructions := {
	#"action": "ABILITY",
	##"ability_id": UID,
	#"opponent_id": Data.opponent_id,
	#"can_cast": true,
#}

func validate(caster_id: String, amx: AbilityMethodsExport) -> Dictionary:
	var caster: Character = amx.get_character_by_id(caster_id)
	var caster_hp = caster.get_node("HpNode")
	var instructions := {
		"ability_id": UID,
		"caster_id": caster_id,
	}
	
	if caster_hp.HP >= caster_hp.MAX_HP:
		instructions.can_cast = false
		instructions.reason = "%s is already at full health" % caster.name
		return instructions
	
	var hp_lost = caster_hp.MAX_HP - caster_hp.HP
	instructions.heal_amt = min(hp_lost, heal_amt)
	instructions.can_cast = true
	instructions.target_type = "OCCUPANT"
	instructions.vectors = {"target_coords": caster.grid_pos}
	
	return instructions


func cast(amx: AbilityMethodsExport, instructions: Dictionary) -> void:
	var caster: Character = amx.get_character_by_id(instructions.caster_id)
	caster.get_node("HpNode").take_healing(instructions.heal_amt)
	#$AudioStreamPlayer.play()
	SoundManager.play_audio_stream(sound)
	var heal_animation: CPUParticles3D = HEAL_10.instantiate()
	caster.add_child(heal_animation)
	heal_animation.connect("finished", heal_animation.queue_free)
	heal_animation.emitting = true
