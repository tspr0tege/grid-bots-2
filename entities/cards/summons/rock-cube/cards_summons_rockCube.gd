extends Character

func _handle_character_death() -> void:
	var death_particles = $CPUParticles3D.duplicate()
	get_parent().add_child(death_particles)
	death_particles.position = self.global_position
	death_particles.emitting = true
	self.queue_free()
