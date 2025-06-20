class_name Character extends Node3D


signal character_death(source)

var grid_pos: Vector2i
var health_display: Label3D
var tile_move_speed := .1
var base_attack: Ability

@export var control_group := Data.CGs.NONE
@export var move_handler: MovementStyle
@export var teleport_enabled := false
@export var diagonal_move_enabled := false
@export var display_health: bool = false
@export var BASE_ATTACK: PackedScene
@export_range(-1, 1, 2) var attack_direction = 1


func _ready() -> void:
	if BASE_ATTACK:
		base_attack = BASE_ATTACK.instantiate()
		add_child(base_attack)
	
	if display_health:
		health_display = Label3D.new()
		health_display.offset.y = -50
		health_display.set_billboard_mode(1)
		health_display.no_depth_test = true
		health_display.text = str(floori($HpNode.HP))
		add_child(health_display)


func move_to(new_pos: Vector3, pushed := false) -> void:
	if !pushed and move_handler:
		move_handler.move(self, new_pos)
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos, tile_move_speed)


func use_base_attack(arena: Node3D) -> void:
	if base_attack:
		base_attack.use_ability(self, arena)
	else:
		push_error("%s's use_base_attack function was called, with no BASE_ATTACK Script assigned." % self.name)


func _on_hp_node_hp_changed(new_amt: float) -> void:
	if display_health:
		health_display.text = str(floori(new_amt))


func _handle_character_death() -> void:
	
	await get_tree().create_timer(.2).timeout
	emit_signal("character_death", self)
	queue_free()
