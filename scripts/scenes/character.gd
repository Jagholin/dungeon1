class_name CharacterController
extends Node3D

var wall_tester: Level
var coordinates: Vector2i = Vector2i.ZERO
var direction: Vector2i = Vector2i(0, -1)

func apply_coordinates():
	position = Vector3(coordinates.x * 2 + 0.5, position.y, coordinates.y * 2 + 0.5)
	
func apply_direction():
	if direction.y == -1:
		rotation = Vector3(0, 0, 0)
	elif direction.x == -1:
		rotation = Vector3(0, PI / 2.0, 0)
	elif direction.y == 1:
		rotation = Vector3(0, PI, 0)
	elif direction.x == 1:
		rotation = Vector3(0, 3.0 * PI / 2.0, 0)

func _input(event):
	var destination: Vector2i
	var newDirection: Vector2i = direction
	var isDirectionChange = false
	var isDestinationChange = false
	if Input.is_action_just_pressed("forward"):
		destination = coordinates + direction
		isDestinationChange = true
	if Input.is_action_just_pressed("backward"):
		destination = coordinates - direction
		isDestinationChange = true
	if Input.is_action_just_pressed("left"):
		newDirection = Vector2i(direction.y, -direction.x)
		isDirectionChange = true
	if Input.is_action_just_pressed("right"):
		newDirection = Vector2i(-direction.y, direction.x)
		isDirectionChange = true
	if Input.is_action_just_pressed("strafe_left"):
		var myDirection := Vector2i(direction.y, -direction.x)
		destination = coordinates + myDirection
		isDestinationChange = true
	if Input.is_action_just_pressed("strafe_right"):
		var myDirection := Vector2i(-direction.y, direction.x)
		destination = coordinates + myDirection
		isDestinationChange = true
	
	if isDirectionChange:
		direction = newDirection
		apply_direction()
		
	if isDestinationChange:
		if wall_tester.is_a_wall(destination.x, destination.y):
			return
		coordinates = destination
		apply_coordinates()
	
func _process(delta):
	pass
