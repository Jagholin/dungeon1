class_name CharacterController
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var step_sound_player: AudioStreamPlayer = $StepSoundsPlayer
@onready var grid_movement: GridMovementComponent = $GridMovementComponent

enum MovementCommand { LEFT_COMMAND, RIGHT_COMMAND, FORWARD_COMMAND, BACK_COMMAND, STRAFE_LEFT_COMMAND, STRAFE_RIGHT_COMMAND }
var command_queue: Array[MovementCommand] = []

const KEY_ITEM_NAME := "KEY"
var inventory = []

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
	
func _input(_event):
	# limit command queue to 1 command
	if command_queue.size() >= 1:
		return
	if Input.is_action_just_pressed("forward"):
		command_queue.push_back(MovementCommand.FORWARD_COMMAND)
	if Input.is_action_just_pressed("backward"):
		command_queue.push_back(MovementCommand.BACK_COMMAND)
	if Input.is_action_just_pressed("left"):
		command_queue.push_back(MovementCommand.LEFT_COMMAND)
	if Input.is_action_just_pressed("right"):
		command_queue.push_back(MovementCommand.RIGHT_COMMAND)
	if Input.is_action_just_pressed("strafe_left"):
		command_queue.push_back(MovementCommand.STRAFE_LEFT_COMMAND)
	if Input.is_action_just_pressed("strafe_right"):
		command_queue.push_back(MovementCommand.STRAFE_RIGHT_COMMAND)
	
func _process(_delta):
	if grid_movement.movement_state != GridMovementComponent.IDLE_STATE:
		return
	var next_command: MovementCommand
	if command_queue.is_empty():
		# special case: if the queue is empty, but the player still holds the 
		# movement button, execute that movement immediately
		var pressedCommands: Array[MovementCommand] = []
		if Input.is_action_pressed("forward"):
			pressedCommands.push_back(MovementCommand.FORWARD_COMMAND)
		if Input.is_action_pressed("backward"):
			pressedCommands.push_back(MovementCommand.BACK_COMMAND)
		if Input.is_action_pressed("left"):
			pressedCommands.push_back(MovementCommand.LEFT_COMMAND)
		if Input.is_action_pressed("right"):
			pressedCommands.push_back(MovementCommand.RIGHT_COMMAND)
		if Input.is_action_pressed("strafe_left"):
			pressedCommands.push_back(MovementCommand.STRAFE_LEFT_COMMAND)
		if Input.is_action_pressed("strafe_right"):
			pressedCommands.push_back(MovementCommand.STRAFE_RIGHT_COMMAND)
		
		if pressedCommands.size() != 1:
			return
		next_command = pressedCommands[0]
	else:
		next_command = command_queue.pop_front() as MovementCommand

	if next_command == MovementCommand.FORWARD_COMMAND:
		grid_movement.move_forward()
	if next_command == MovementCommand.BACK_COMMAND:
		grid_movement.move_backward()
	if next_command == MovementCommand.LEFT_COMMAND:
		grid_movement.rotate_left()
	if next_command == MovementCommand.RIGHT_COMMAND:
		grid_movement.rotate_right()
	if next_command == MovementCommand.STRAFE_LEFT_COMMAND:
		grid_movement.strafe_left()
	if next_command == MovementCommand.STRAFE_RIGHT_COMMAND:
		grid_movement.strafe_right()
	
func on_item_pickup(item_name: String):
	print("Item added: {0}".format([item_name]))
	Globals.get_current_level().show_notice("You picked up: {0}".format([item_name]))
	inventory.push_back(item_name)
	
func try_open_door(d: Door) -> bool:
	var key_item = inventory.find(KEY_ITEM_NAME)
	if key_item == -1:
		return false
	d.open_door()
	inventory.remove_at(key_item)
	return true

func get_component(componentClassName: StringName) -> Component:
	for c in get_children():
		if Component.is_a_component(c) and componentClassName in c.get_component_names():
			return c as Component
	return null
