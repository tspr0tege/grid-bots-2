extends Ability

const HEAL_10 = preload("res://abilities/buffs/heal-10/object_heal-10.tscn")
const heal_amt = 10
#var instructions := {
	#"action": "ABILITY",
	##"ability_id": UID,
	#"opponent_id": Data.opponent_id,
	#"can_cast": true,
#}

func validate(caster: Character, _arena: Node3D) -> Dictionary:
	var caster_hp = caster.get_node("HpNode")
	instructions.ability_id = UID	
	
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


func cast(_arena: Node3D, final_instructions: Dictionary) -> void:
	var caster = final_instructions.target
	caster.get_node("HpNode").take_healing(final_instructions.heal_amt)
	var heal_animation: CPUParticles3D = HEAL_10.instantiate()
	caster.add_child(heal_animation)
	heal_animation.connect("finished", heal_animation.queue_free)
	heal_animation.emitting = true
