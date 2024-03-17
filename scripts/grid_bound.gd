class_name GridBoundComponent
extends Component

var grid_coordinate: Vector3i
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
