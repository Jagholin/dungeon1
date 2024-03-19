class_name PlayerTrackerComponent
extends Component

const PLAYERTRACKER_COMPONENT_NAME := &"PlayerTrackerComponent"

@export var movement_listener: MovementListenerComponent
@export var grid_bound: GridBoundComponent

func on_player_collision():
	if target.has_method(&"on_player_collision"):
		target.on_player_collision()

func _ready():
	if movement_listener:
		movement_listener.player_collision.connect(on_player_collision)

func get_component_name() -> StringName:
	return PLAYERTRACKER_COMPONENT_NAME

func get_component_names() -> Array[StringName]:
	var temp := super.get_component_names()
	temp.push_back(PLAYERTRACKER_COMPONENT_NAME)
	return temp
