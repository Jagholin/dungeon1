## Component for entities that listen to player's attempted movements before they are executed
## and can interfere with them(for example, a door)
class_name MovementListenerComponent
extends Component

const MOVELISTENER_COMPONENT_NAME := &"MovementListenerComponent"

@export var grid_bound: GridBoundComponent
@export var is_an_obstacle: bool = true

signal player_collision

enum MovementEffect {NONE, PREVENT_MOVEMENT}
func on_movement_initiated(dest: Vector3i) -> MovementEffect:
	if dest != grid_bound.grid_coordinate:
		return MovementEffect.NONE
	assert(target.has_method(&"on_movement_initiated"))
	player_collision.emit()
	return target.on_movement_initiated()

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		# get the Character object and register in its movement listeners
		var chr := get_tree().get_first_node_in_group(Globals.CHARACTER_GROUP) as CharacterController
		var component := chr.get_component(GridMovementComponent.GM_COMPONENT_NAME)
		component.remove_movement_listener(self)
		if is_an_obstacle:
			Obstacles.unregister_obstacle(grid_bound.grid_coordinate)

func _ready():
	# get the Character object and register in its movement listeners
	var chr := get_tree().get_first_node_in_group(Globals.CHARACTER_GROUP) as CharacterController
	# TODO:  implement movement listener array as a part of a system?
	var component := chr.get_component(GridMovementComponent.GM_COMPONENT_NAME)
	component.add_movement_listener(self)
	await grid_bound.grid_coordinate_changed
	if is_an_obstacle:
		Obstacles.register_obstacle(grid_bound.grid_coordinate)

func get_component_name() -> StringName:
	return MOVELISTENER_COMPONENT_NAME

func get_component_names() -> Array[StringName]:
	var temp := super.get_component_names()
	temp.push_back(MOVELISTENER_COMPONENT_NAME)
	return temp
