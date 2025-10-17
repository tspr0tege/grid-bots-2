extends Node

enum CGs { NONE, RED, BLUE, UNIVERSAL } #Control Groups

var multiplayer_id = null
var opponent_id = null

var ability_deck = {}

func opposing_group(character: Character) -> CGs:
	if character.control_group == CGs.RED: return CGs.BLUE
	else: return CGs.RED

func coords_to_dict(coords: Vector2i) -> Dictionary:
	return {"x": coords.x, "y": coords.y}

func coords_from_dict(coords: Dictionary) -> Vector2i:
	return Vector2i(coords.x, coords.y)

func vec2_to_dict(coords: Vector2) -> Dictionary:
	return {"x": coords.x, "y": coords.y}

func vec2_from_dict(coords: Dictionary) -> Vector2:
	return Vector2(coords.x, coords.y)

func vec3_to_dict(coords: Vector3) -> Dictionary:
	return{"x": coords.x, "y": coords.y, "z": coords.z}

func vec3_from_dict(coords: Dictionary) -> Vector3:
	return Vector3(coords.x, coords.y, coords.z)
