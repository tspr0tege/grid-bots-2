extends Node

@export var cam : Camera3D

signal move_by_direction(direction: Vector2i)
signal move_by_coords(coords: Vector2i)

const RAY_LENGTH = 100
var screen_tap_origin: Vector2 = Vector2.ZERO


func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_left"):
		move_by_direction.emit(Vector2i(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move_by_direction.emit(Vector2i(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		move_by_direction.emit(Vector2i(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		move_by_direction.emit(Vector2i(0, 1))


func _physics_process(_delta: float) -> void:
	if screen_tap_origin.length() > 0:
		var space_state = %Arena.get_world_3d().direct_space_state
		var origin = cam.project_ray_origin(screen_tap_origin)
		var end = origin + cam.project_ray_normal(screen_tap_origin) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		
		if result and ("grid_coordinates" in result.collider):
			move_by_coords.emit(result.collider.grid_coordinates)
		
		screen_tap_origin = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	# Events are triggered when the screen is touched, and when the touch ends.
	# Positions are recorded at these two events
	if event is InputEventScreenTouch and event.pressed: 
		print("Touch screen pressed")
		screen_tap_origin = event.position
