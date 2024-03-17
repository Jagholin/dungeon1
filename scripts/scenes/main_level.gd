class_name Level
extends Node3D

@onready var grid_map: GridMap = $GridMap
var mesh_library: MeshLibrary
@onready var character: CharacterController = $Character
@onready var key_item: KeyItem = $key_placeholder
@onready var notice_label: Label = %NoticeLabel

# var doors: Array[Door] = []
func get_doors():
	return get_tree().get_nodes_in_group("door")

func show_notice(n: String):
	notice_label.text = n
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		notice_label.text = "")

## returns trus if the tile at (x, y) is a wall
## tests the name of the tile and if it has "wall" in it returns true
func is_a_wall(x, z) -> bool:
	var item := grid_map.get_cell_item(Vector3i(x, 0, z))
	for d in get_doors():
		if not d.closed:
			continue
		if d.grid_coordinate.x == x and d.grid_coordinate.z == z:
			var wasOpened := try_open_door(d)
			if not d.closed:
				return false
			show_notice("You need a key to open this door")
			return true
	return mesh_library.get_item_name(item).contains("wall")

func _ready():
	character.level = self
	mesh_library = grid_map.mesh_library
	# var item := grid_map.get_cell_item(Vector3i(1, 0, 1))
	
	# print("The item in 1,1 is {0}".format([item]))
	# item = grid_map.get_cell_item(Vector3i(0, 0, 0))
	
	# print("The item in 0,0 is {0} has the name {1}".format([item, mesh_library.get_item_name(item)]))
	
	# find all doors and add them to the door array
	for c in get_doors():
		c.initialize(self)
	
	key_item.after_ready()
	
func map_global_to_gridcoord(c: Vector3) -> Vector3i:
	var localGridTestPoint := grid_map.to_local(c)
	return grid_map.local_to_map(localGridTestPoint)
	
func try_open_door(d: Door) -> bool:
	return character.try_open_door(d)
