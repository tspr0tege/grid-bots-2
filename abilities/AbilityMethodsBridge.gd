class_name AbilityMethodsBridge extends RefCounted

var ARENA : Arena
var MATCH_CONTROLLER : MatchController


func _init(new_arena: Node3D, new_match_controller: Node):
	ARENA = new_arena
	MATCH_CONTROLLER = new_match_controller

#get_character_by_id
#add_new_character (ActorFactory and place)
