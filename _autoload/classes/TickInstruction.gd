class_name TickInstruction extends Object

enum action_types {
	MOVE
}

const action_type_names := [
	"move",
]

var target_tick : int
var revision : int
var actor_type : String
var actor_id : String
var action_type : String
var action_instructions : Dictionary

func _init(
	new_target_tick : int,
	new_revision : int,
	new_actor_type : String,
	new_actor_id : String,
	new_action_type : action_types,
	new_action_instructions : Dictionary
) -> void:
	target_tick = new_target_tick
	revision = new_revision
	actor_type = new_actor_type
	actor_id = new_actor_id
	action_type = action_type_names[int(new_action_type)]
	action_instructions = new_action_instructions
