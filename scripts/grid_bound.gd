
## Component class for entities that are bound to the game's grid
## (either free-floating or mounted on the wall)
## Retrieves their coordinate at the start of the level.
class_name GridBoundComponent
extends Component

const GB_COMPONENT_NAME := &"GridBoundComponent"

signal grid_coordinate_changed(c: Vector3i)
var grid_coordinate: Vector3i:
	set(newValue):
		if newValue == grid_coordinate:
			return
		grid_coordinate = newValue
		grid_coordinate_changed.emit(newValue)

@export var on_the_wall: bool = true

func _init():
	add_to_group(&"after_ready")

func after_ready(l: Level):
	# calculate coordinate on the GridMap
	# local coordinate for some point inside the cell that the key "points" to
	# cells are 2 units long, so 1.0 would be roughly in a middle of a cell
	var localTestPoint := Vector3(0, 0, 1.0) if on_the_wall else Vector3.ZERO
	var globalTestPoint := target.to_global(localTestPoint)
	grid_coordinate = l.map_global_to_gridcoord(globalTestPoint)
	
	print("grid coordinate of a key is {0}", grid_coordinate)

func get_component_name() -> StringName:
	return GB_COMPONENT_NAME

func get_component_names() -> Array[StringName]:
	var temp := super.get_component_names()
	temp.push_back(GB_COMPONENT_NAME)
	return temp
