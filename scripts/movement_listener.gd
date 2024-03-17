class_name MovementListenerComponent
extends Component

@export var grid_bound: GridBoundComponent

enum MovementEffect {NONE, PREVENT_MOVEMENT}
func on_movement_initiated(dest: Vector3i) -> MovementEffect:
	if dest != grid_bound.grid_coordinate:
		return MovementEffect.NONE
	assert(target.has_method(&"on_movement_initiated"))
	return target.on_movement_initiated()

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		# get the Character object and register in its movement listeners
		var chr := get_tree().get_first_node_in_group(Globals.CHARACTER_GROUP) as CharacterController
		chr.remove_movement_listener(self)

func _ready():
	# get the Character object and register in its movement listeners
	var chr := get_tree().get_first_node_in_group(Globals.CHARACTER_GROUP) as CharacterController
	chr.add_movement_listener(self)
