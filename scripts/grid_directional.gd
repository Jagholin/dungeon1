## Component for entities that have both grid coordinate and direction.
class_name GridDirectionalComponent
extends GridBoundComponent

signal grid_direction_changed(dir: Vector3i)
var grid_direction: Vector3i:
	set(newValue):
		if grid_direction == newValue:
			return
		grid_direction = newValue
		grid_direction_changed.emit(newValue)

func after_ready(l: Level):
	# this initializes grid_coordinate
	super.after_ready(l)

	assert(not on_the_wall, "GridDirectionalComponent is for entities that are not mounted to walls")
	# negative Z is the forward direction
	var testPoint := target.to_global(Vector3(0, 0, -Globals.TILE_SIZE))
	grid_direction = l.map_global_to_gridcoord(testPoint) - grid_coordinate
	print("GridDirectionalComponent: Grid direction of ", grid_direction)

func get_component_name() -> StringName:
	return &"GridDirectionalComponent"

