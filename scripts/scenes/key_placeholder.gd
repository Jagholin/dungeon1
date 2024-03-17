class_name KeyItem
extends Node3D

@onready var physics_body: StaticBody3D = $key/StaticBody3D

signal item_pickup(name: String)
func emit_pickup_signal():
	item_pickup.emit(ITEM_NAME)

var grid_coordinate: Vector3i
var can_be_pickedup: bool = false

const ITEM_NAME := CharacterController.KEY_ITEM_NAME

@export var grid_map: GridMap
@export var level: Level

func _ready():
	print("ready entered")
	# calculate coordinate on the GridMap
	# local coordinate for some point inside the cell that the key "points" to
	# cells are 2 units long, so 1.0 would be roughly in a middle of a cell

func after_ready():
	var localTestPoint := Vector3(0, 0, 1.0)
	var globalTestPoint := to_global(localTestPoint)
	grid_coordinate = level.map_global_to_gridcoord(globalTestPoint)
	
	print("grid coordinate of a key is {0}", grid_coordinate)
	
func _on_static_body_3d_mouse_entered():
	print("Mouse entered yay")

func _on_static_body_3d_mouse_exited():
	print("Mouse exited ohh")

func on_character_coordinate_changed(c: Vector2i):
	# test if the character is in the same location as the key item
	if c.x == grid_coordinate.x and c.y == grid_coordinate.z:
		print("character can pick up the key")
		can_be_pickedup = true
	else:
		can_be_pickedup = false

func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if not can_be_pickedup:
		return
	if event is InputEventMouseButton:
		var realEvent := event as InputEventMouseButton
		if realEvent.button_index == MOUSE_BUTTON_LEFT and realEvent.pressed:
			print("you clicked on the thing")
			emit_pickup_signal()
			# destroy the item
			queue_free()
