extends Card

@export var dmg: float = 30.0

const CANNON = preload("res://cards/instant-shot/cannon/cannon.tscn")
# x 0.1   y 0.33   z 0.2

func play_card(caster : Character, arena : Node3D) -> void:
	var new_cannon = CANNON.instantiate()
	new_cannon.position = Vector3(0.1, 0.33, 0.2)
	new_cannon.get_node("AnimationPlayer").play("shoot")
	new_cannon.get_node("Blast").connect("finished", new_cannon.queue_free)
	caster.add_child(new_cannon)
	
	var target = arena.linear_search(caster, "CHARACTER")
	if target: target.get_node("HpNode").take_damage(dmg)
