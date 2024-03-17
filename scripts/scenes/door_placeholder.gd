class_name Door
extends Node3D

@export var closed: bool = true

var grid_coordinate: Vector3i

func initialize(l: Level):
	grid_coordinate = l.map_global_to_gridcoord(global_position)
	print("door: my coordinate is {0}".format([grid_coordinate]))
	
func open_door():
	closed = false
	queue_free()
