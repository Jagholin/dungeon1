extends Node

const CHARACTER_GROUP = &"character"
const DOOR_GROUP = &"door"
const APP_GROUP = &"app"
const AFTER_READY_GROUP = &"after_ready"

func get_character_controller() -> CharacterController:
	return get_tree().get_first_node_in_group(CHARACTER_GROUP) as CharacterController

func get_current_level() -> Level:
	var app := get_tree().get_first_node_in_group(APP_GROUP) as AppMain
	return app.level
