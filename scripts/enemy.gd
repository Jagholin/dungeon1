class_name Enemy
extends Node3D

@onready var movement: AIMovementComponent = $AIMovementComponent

func _ready():
	# await get_tree().create_timer(1.0).timeout
	await movement.grid_coordinate_changed
	print("enemy position is ", movement.grid_coordinate)
	movement.move_to(Vector3i(0, 0, 0))
