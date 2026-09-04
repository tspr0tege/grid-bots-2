class_name FloorTile extends Area3D

enum tile_states {
	NORMAL,
	CRACKED,
	BROKEN,
	REVERTING_SOON,
	WAITING_TO_REVERT,
	#elemental
	#captured?
}

var grid_coordinates : Vector2i
var team : MatchSettings.teams
var is_occupied := false
var occupant : Character
var traversable := true
var reserved := false
var state : tile_states = tile_states.NORMAL
var projectiles := {}


func set_team(group: MatchSettings.teams, reset_in: float = 0.0) -> void:
	#print("Changing control group to " + str(group))
	if reset_in > 0:
		var current_group = team
		get_tree().create_timer(reset_in).timeout.connect(set_team.bind(current_group))
	
	team = group
	var tile_material = $MeshInstance3D.get_surface_override_material(0)
	
	if group == MatchSettings.player_team:
		tile_material.albedo_color = Color(0, 0, .9)
	else:
		tile_material.albedo_color = Color(.9, .2, .2)


func add_occupant(new_occupant: Character) -> void:
	occupant = new_occupant
	is_occupied = true
	reserved = false


func remove_occupant() -> void:
	occupant = null
	is_occupied = false


func add_projectile(projectile: ProjectileController) -> void:
	var projectile_id: String = projectile.projectile_id
	projectiles[projectile_id] = projectile


func remove_projectile(projectile: ProjectileController) -> void:
	var projectile_id: String = projectile.projectile_id
	if projectiles.has(projectile_id):
		projectiles.erase(projectile_id)
	#else:
		#push_warning("Attempting to remove a projectile from floor_tile, that is not stored in its dictionary")


func break_tile() -> void:
	$MeshInstance3D.visible = false
	state = tile_states.BROKEN
	traversable = false
	get_tree().create_timer(10).timeout.connect(repair_tile)


func repair_tile() -> void:
	$MeshInstance3D.visible = true
	state = tile_states.NORMAL
	traversable = true
