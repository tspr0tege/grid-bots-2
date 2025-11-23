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
@export var animation_player: AnimationPlayer
#const available_animations = ["shoot", "move", "run", "ready", "punch"]
@export_range(-1, 1, 2) var attack_direction = 1


func _ready() -> void:
	if BASE_ATTACK:
		base_attack = BASE_ATTACK.instantiate()
		base_attack.COST = 0
		Data.ability_deck[base_attack.UID] = base_attack
		add_child(base_attack)
	
	if display_health:
		health_display = Label3D.new()
		health_display.offset.y = -50
		health_display.set_billboard_mode(BaseMaterial3D.BillboardMode.BILLBOARD_ENABLED)
		health_display.no_depth_test = true
		health_display.text = str(floori($HpNode.HP))
		add_child(health_display)
	
	if animation_player:
		animation_player.connect("animation_finished", _on_animation_finished)


func animate_action(animation_name) -> void:
	if !is_instance_valid(animation_player): 
		print("No AnimationPlayer assigned to %s. Unable to run %s animation." % [self.name, animation_name])
		return
	
	if attack_direction < 1: animation_name += "2"
	
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	else:
		print("%s does not have an animation named %s" % [self.name, animation_name])


func _on_animation_finished(anim_name: String) -> void:
	if !anim_name.begins_with("ready"):
		animation_player.play("ready" if attack_direction > 0 else "ready2")


func move_to(new_pos: Vector3, pushed := false) -> void:
	if !pushed and move_handler:
		move_handler.move(self, new_pos)
	else:
		var new_tween = get_tree().create_tween()
		new_tween.tween_property(self, "position", new_pos, tile_move_speed)


func use_base_attack(arena: Node3D) -> void:
	if base_attack:
		arena._attempt_ability(self, base_attack)
	else:
		push_error("%s's use_base_attack function was called, with no BASE_ATTACK Script assigned." % self.name)


func _on_hp_node_hp_changed(new_amt: float) -> void:
	if display_health:
		health_display.text = str(floori(new_amt))


func _handle_character_death() -> void:
	emit_signal("character_death", self)
	await get_tree().create_timer(.2).timeout
	queue_free()
