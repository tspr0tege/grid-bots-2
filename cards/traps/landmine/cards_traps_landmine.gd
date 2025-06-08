extends Trap3D

@onready var smoke: CPUParticles3D = $Explosion/Smoke
@onready var fire: CPUParticles3D = $Explosion/Fire
@onready var sparks: CPUParticles3D = $Explosion/Sparks
@export var dmg: float = 25.0

func trigger_trap(trigger_cause: Character) -> void:
	#class contains reference to grid_coordinates
	$MeshInstance3D.visible = false
	trigger_cause.get_node("HpNode").take_damage(dmg)
	smoke.connect("finished", queue_free)
	smoke.emitting = true
	fire.emitting = true
	sparks.emitting = true
