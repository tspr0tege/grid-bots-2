class_name AbilityMethodsRegister
extends Resource



func request_cast() -> void:
	pass


func cast(_amx : AbilityMethodsExport, _instructions: Dictionary) -> void:

	pass

#Possible behavior JSON entries:
	#{
		#speed (ticks per tile)
		#direction Vector2()
	#Projectile specific:
		#in_strike_zone, collision_check_active, or can_damage? (not sure on wording yet)
		#cascade_effects (next ability call, or instantiated copy)
		#on_collision = what to do when projectile collides with character
		#travel_behavior (linear, diagonal, bounce, etc - matched up with server functions)
		#travel_props - parameters to pass into travel behavior function
		#can_penetrate - bool
		#penetration_limit - int
		#friendly_fire - bool (quit hittin' yer'self)
	#}
