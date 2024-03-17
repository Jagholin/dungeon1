class_name Door
extends Node3D

@onready var grid_bound: GridBoundComponent = $GridBoundComponent
@export var closed: bool = true

var grid_coordinate: Vector3i:
	get:
		return grid_bound.grid_coordinate
	
func open_door():
	closed = false
	# queue_free()
	visible = false

func on_movement_initiated():
	print("Movement initiated caught")
	var currentLevel := Globals.get_current_level()

	if closed:
		var wasOpened := try_open_door()
		if not wasOpened:
			currentLevel.show_notice("You need a key to open this door")
		return MovementListenerComponent.MovementEffect.PREVENT_MOVEMENT
	return MovementListenerComponent.MovementEffect.NONE

func try_open_door() -> bool:
	var chr := Globals.get_character_controller()
	return chr.try_open_door(self)
