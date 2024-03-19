class_name Enemy
extends Node3D

@onready var movement: AIMovementComponent = $GridMovementComponent

func coord_to_position(c: Vector3i) -> Vector3:
	return Vector3(c.x * 2, position.y, c.z * 2)
	
func dir_to_rotation(c: Vector3i) -> Vector3:
	if c.z == -1:
		return Vector3(0, 0, 0)
	elif c.x == -1:
		return Vector3(0, PI / 2.0, 0)
	elif c.z == 1:
		return Vector3(0, PI, 0)
	elif c.x == 1:
		return Vector3(0, 3.0 * PI / 2.0, 0)
	push_error("Unexpected direction value, {0}".format([c]))
	return Vector3(0, 0, 0)

func _ready():
	# await get_tree().create_timer(1.0).timeout
	await movement.grid_coordinate_changed
	print("enemy position is ", movement.grid_coordinate)

func _on_timer_timeout():
	var cmp := Globals.get_character_controller().get_component(GridBoundComponent.GB_COMPONENT_NAME) as GridBoundComponent
	var goal := cmp.grid_coordinate

	var result := movement.approach(goal)
	if result == AIMovementComponent.POSITION_REACHED:
		print("Hi there!")
	elif result == AIMovementComponent.NO_PATH:
		print("No path :(")
