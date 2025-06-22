extends Trap3D

@onready var smoke: CPUParticles3D = $Explosion/Smoke
@onready var fire: CPUParticles3D = $Explosion/Fire
@onready var sparks: CPUParticles3D = $Explosion/Sparks


func trigger_trap() -> void:
	#class contains reference to grid_coordinates
	$MeshInstance3D.visible = false
	smoke.connect("finished", queue_free)
	smoke.emitting = true
	fire.emitting = true
	sparks.emitting = true
