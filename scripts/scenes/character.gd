class_name CharacterController
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var step_sound_player: AudioStreamPlayer = $StepSoundsPlayer

var level: Level

var new_direction: Vector2i
var new_coordinates: Vector2i

var game_state: GameState

const walk_animation_name := "walk"
const turn_animation_name := "turn"
const wall_animation_name := "wallbump"

const IDLE_STATE := "IDLE"
const WALKING_STATE := "WALKING"
const TURNING_STATE := "TURNING"
const WALL_BUMP_STATE := "WALL_BUMP"
const COOLDOWN_STATE := "COOLDOWN"
## "IDLE", "WALKING", "TURNING", "COOLDOWN" or "WALL_BUMP"
var movement_state := IDLE_STATE

enum MovementCommand { LEFT_COMMAND, RIGHT_COMMAND, FORWARD_COMMAND, BACK_COMMAND, STRAFE_LEFT_COMMAND, STRAFE_RIGHT_COMMAND }
var command_queue: Array[MovementCommand] = []

const KEY_ITEM_NAME := "KEY"
var inventory = []
var movement_listeners: Array[MovementListenerComponent] = []

func add_movement_listener(listener: MovementListenerComponent):
	movement_listeners.push_back(listener)
func remove_movement_listener(listener: MovementListenerComponent):
	movement_listeners.remove_at(movement_listeners.find(listener))

func _notification(what):
	if what == NOTIFICATION_ENTER_TREE and not game_state:
		var appNode := get_tree().get_first_node_in_group("app") as AppMain
		assert(appNode)
		game_state = appNode.game_state

## this property is driven by the AnimationPlayer
## the starting value is always 0.0, the end value is 1.0 and indicates animation end
##
## TODO: rewrite using Transform3D ?
@export_range(0.0, 1.0) var blend_value: float = 0.0:
	set(newValue):
		# print("setter called, {0}".format([newValue]))
		if newValue == blend_value:
			return
		# assert(movement_state != IDLE_STATE)
		blend_value = newValue
		if movement_state == WALKING_STATE or movement_state == WALL_BUMP_STATE:
			var startPos := coord_to_position(game_state.character_coordinates)
			var endPos := coord_to_position(new_coordinates)
			position = (1.0 - blend_value) * startPos + blend_value * endPos
		elif movement_state == TURNING_STATE:
			var startRot := dir_to_rotation(game_state.character_direction)
			var endRot := dir_to_rotation(new_direction)
			# candidate rotations for the end
			var endRots := [endRot, endRot + Vector3(0, 2 * PI, 0), endRot - Vector3(0, 2 * PI, 0)]
			# select end rotation that is closest to the starting one from endRots
			endRot = endRots[0]
			endRot = endRots[1] if (endRots[1] - startRot).abs() < (endRot - startRot).abs() else endRot
			endRot = endRots[2] if (endRots[2] - startRot).abs() < (endRot - startRot).abs() else endRot
			rotation = (1.0 - blend_value) * startRot + blend_value * endRot

func coord_to_position(c: Vector2i) -> Vector3:
	return Vector3(c.x * 2, position.y, c.y * 2)
	
func dir_to_rotation(c: Vector2i) -> Vector3:
	if c.y == -1:
		return Vector3(0, 0, 0)
	elif c.x == -1:
		return Vector3(0, PI / 2.0, 0)
	elif c.y == 1:
		return Vector3(0, PI, 0)
	elif c.x == 1:
		return Vector3(0, 3.0 * PI / 2.0, 0)
	push_error("Unexpected direction value")
	return Vector3(0, 0, 0)
	

func apply_coordinates():
	blend_value = 0.0
	movement_state = WALKING_STATE
	animation_player.play(walk_animation_name)
	step_sound_player.play()
	
func apply_direction():
	blend_value = 0.0
	movement_state = TURNING_STATE
	animation_player.play(turn_animation_name)
	step_sound_player.play()

func apply_wall_bump():
	blend_value = 0.0
	movement_state = WALL_BUMP_STATE
	animation_player.play(wall_animation_name)

func apply_cooldown():
	movement_state = COOLDOWN_STATE
	var t := create_tween()
	t.tween_interval(0.3)
	t.tween_callback(func(): movement_state = IDLE_STATE)
	
func _ready():
	# sync position and rotation to the current coordinates
	position = coord_to_position(game_state.character_coordinates)
	rotation = dir_to_rotation(game_state.character_direction)
	
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
	if movement_state != IDLE_STATE:
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

	var destination: Vector2i
	var direction := game_state.character_direction
	var coordinates := game_state.character_coordinates
	var newDirection: Vector2i = direction
	var isDirectionChange = false
	var isDestinationChange = false
	if next_command == MovementCommand.FORWARD_COMMAND:
		destination = coordinates + direction
		isDestinationChange = true
	if next_command == MovementCommand.BACK_COMMAND:
		destination = coordinates - direction
		isDestinationChange = true
	if next_command == MovementCommand.LEFT_COMMAND:
		newDirection = Vector2i(direction.y, -direction.x)
		isDirectionChange = true
	if next_command == MovementCommand.RIGHT_COMMAND:
		newDirection = Vector2i(-direction.y, direction.x)
		isDirectionChange = true
	if next_command == MovementCommand.STRAFE_LEFT_COMMAND:
		var myDirection := Vector2i(direction.y, -direction.x)
		destination = coordinates + myDirection
		isDestinationChange = true
	if next_command == MovementCommand.STRAFE_RIGHT_COMMAND:
		var myDirection := Vector2i(-direction.y, direction.x)
		destination = coordinates + myDirection
		isDestinationChange = true
	
	if isDirectionChange:
		new_direction = newDirection
		apply_direction()
		
	if isDestinationChange:
		if level.is_a_wall(destination.x, destination.y):
			new_coordinates = destination
			apply_wall_bump()
			return

		for ml in movement_listeners:
			if ml.on_movement_initiated(Vector3i(destination.x, 0, destination.y)) == MovementListenerComponent.MovementEffect.PREVENT_MOVEMENT:
				apply_cooldown()
				return

		new_coordinates = destination
		apply_coordinates()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == walk_animation_name:
		# finish current movement command and reset blend value
		assert(movement_state == WALKING_STATE)
		game_state.character_coordinates = new_coordinates
		movement_state = IDLE_STATE
		blend_value = 0.0
		position = coord_to_position(game_state.character_coordinates)
		return
	elif anim_name == turn_animation_name:
		assert(movement_state == TURNING_STATE)
		game_state.character_direction = new_direction
		movement_state = IDLE_STATE
		blend_value = 0.0
		rotation = dir_to_rotation(game_state.character_direction)
		return
	elif anim_name == wall_animation_name:
		assert(movement_state == WALL_BUMP_STATE)
		movement_state = IDLE_STATE
		blend_value = 0.0
		return
	# TODO: finish other animations as well
	assert(false, "Unreachable location reached")
	
func on_item_pickup(item_name: String):
	print("Item added: {0}".format([item_name]))
	level.show_notice("You picked up: {0}".format([item_name]))
	inventory.push_back(item_name)
	
func try_open_door(d: Door) -> bool:
	var key_item = inventory.find(KEY_ITEM_NAME)
	if key_item == -1:
		return false
	d.open_door()
	inventory.remove_at(key_item)
	return true
