class_name KeyItem
extends Node3D

@onready var physics_body: StaticBody3D = $key/StaticBody3D
@onready var grid_bound: GridBoundComponent = $GridBoundComponent

signal item_pickup(name: String)
func emit_pickup_signal():
	item_pickup.emit(ITEM_NAME)

var can_be_pickedup: bool = false

const ITEM_NAME := CharacterController.KEY_ITEM_NAME

func _ready():
	print("ready entered")
	# game_state.character_position_changed.connect(on_character_coordinate_changed)
	var charComponent := Globals.get_character_controller().get_component(&"GridDirectionalComponent") as GridDirectionalComponent
	assert(charComponent)
	charComponent.grid_coordinate_changed.connect(on_character_coordinate_changed)
	
func _on_static_body_3d_mouse_entered():
	print("Mouse entered yay")

func _on_static_body_3d_mouse_exited():
	print("Mouse exited ohh")

func on_character_coordinate_changed(c: Vector3i):
	# test if the character is in the same location as the key item
	if c == grid_bound.grid_coordinate:
		print("character can pick up the key")
		can_be_pickedup = true
	else:
		can_be_pickedup = false

func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if not can_be_pickedup:
		return
	if event is InputEventMouseButton:
		var realEvent := event as InputEventMouseButton
		if realEvent.button_index == MOUSE_BUTTON_LEFT and realEvent.pressed:
			print("you clicked on the thing")
			emit_pickup_signal()
			# destroy the item
			queue_free()
