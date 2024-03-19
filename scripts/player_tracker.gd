class_name PlayerTrackerComponent
extends Component

@export var movement_listener: MovementListenerComponent
@export var grid_bound: GridBoundComponent

func on_player_collision():
	if target.has_method(&"on_player_collision"):
		target.on_player_collision()

func _ready():
	if movement_listener:
		movement_listener.player_collision.connect(on_player_collision)

func get_component_name() -> StringName:
	return &"PlayerTrackerComponent"
