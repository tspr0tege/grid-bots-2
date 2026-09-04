class_name Character extends Node3D

signal character_death(source)
#TODO: remove signal and execute ability from the weapon's id
signal request_ability(character: Character, ability: Ability)
signal update_grid_coords(character_id: String, to_coords: Vector2i)

var character_id: String
var grid_coords: Vector2i
var health_display: Label3D
var tile_move_speed := 4
var is_busy := false

@export var base_attack: Ability
@export var team := MatchSettings.teams.NEUTRAL
@export var move_handler: MovementStyle
@export var is_animate: bool = true #true for anything that "acts" (has a controller)
@export var teleport_enabled := false
@export var diagonal_move_enabled := false
@export var display_health: bool = false
@export var animation_player: AnimationPlayer
@export_range(-1, 1, 2) var attack_direction = 1


func _ready() -> void:
	#if BASE_ATTACK:
		#base_attack = BASE_ATTACK.instantiate()
		#Data.ability_deck[base_attack.UID] = base_attack
		#add_child(base_attack)
	
	if display_health:
		health_display = Label3D.new()
		health_display.offset.y = -50
		health_display.set_billboard_mode(BaseMaterial3D.BillboardMode.BILLBOARD_ENABLED)
		health_display.no_depth_test = true
		health_display.text = str(floori($HpNode.HP))
		add_child(health_display)
	
	if animation_player:
		animation_player.connect("animation_finished", _on_animation_finished)


func handle_tick_action(action_type: String, action_instructions: Dictionary) -> void:
	
	match action_type:
		"move":
			update_grid_coords.emit(character_id, action_instructions.to_coords)
			#grid_coords = action_instructions.to_coords
		_:
			push_error("Unhandled action type received in Character.handle_tick_action\n action_type: \t %s\n action_instructions: \t %s" % [action_type, JSON.stringify(action_instructions, "\t")])
			


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


func move_to(new_pos: Vector3) -> void:
	if move_handler:
		move_handler.move(self, new_pos)
	else:
		slide_to(new_pos)
	
	animate_action("move")


func slide_to(new_pos: Vector3) -> void:
	var new_tween = get_tree().create_tween()
	new_tween.tween_property(self, "position", new_pos, float(tile_move_speed) / 40)


func use_base_attack() -> void:
	if base_attack:
		request_ability.emit(self, base_attack)
	else:
		push_error("%s has no BASE_ATTACK ability." % self.name)


func _on_hp_node_hp_changed(new_amt: float) -> void:
	if display_health:
		health_display.text = str(floori(new_amt))


func _handle_character_death() -> void:
	emit_signal("character_death", self)
	await get_tree().create_timer(.2).timeout
	queue_free()
