class_name Level
extends Node3D

@onready var grid_map: GridMap = $GridMap
var mesh_library: MeshLibrary
@onready var character: CharacterController = $Character

## returns trus if the tile at (x, y) is a wall
## tests the name of the tile and if it has "wall" in it returns true
func is_a_wall(x, z) -> bool:
	var item := grid_map.get_cell_item(Vector3i(x, 0, z))
	return mesh_library.get_item_name(item).contains("wall")

func _ready():
	character.wall_tester = self
	mesh_library = grid_map.mesh_library
	var item := grid_map.get_cell_item(Vector3i(1, 0, 1))
	
	print("The item in 1,1 is {0}".format([item]))
	item = grid_map.get_cell_item(Vector3i(0, 0, 0))
	
	print("The item in 0,0 is {0} has the name {1}".format([item, mesh_library.get_item_name(item)]))