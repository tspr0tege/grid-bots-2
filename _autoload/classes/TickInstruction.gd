class_name TickInstruction extends Object

enum action_types {
	MOVE,
	FIZZLE,
	COLLISION,
}

const action_type_names := [
	"move",
	"fizzle",
	"collision",
]

var kickoff_tick : int
var revision : int
var actor_type : String
var actor_id : String
var action_type : String
var action_instructions : Dictionary

func _init(
	new_kickoff_tick : int,
	new_revision : int,
	new_actor_type : String,
	new_actor_id : String,
	new_action_type : action_types,
	new_action_instructions : Dictionary
) -> void:
	kickoff_tick = new_kickoff_tick
	revision = new_revision
	actor_type = new_actor_type
	actor_id = new_actor_id
	action_type = action_type_names[int(new_action_type)]
	action_instructions = new_action_instructions
