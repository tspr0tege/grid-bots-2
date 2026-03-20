extends Obstacle

@export var death_sound : SoundResource

func _handle_character_death() -> void:
	emit_signal("character_death", self)
	SoundManager.play_audio_stream(death_sound)
	var death_particles = $CPUParticles3D.duplicate()
	get_parent().add_child(death_particles)
	death_particles.position = self.global_position
	death_particles.emitting = true
	self.queue_free()
