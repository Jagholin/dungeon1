class_name CharacterController
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var wall_tester: Level
var coordinates: Vector2i = Vector2i.ZERO
var direction: Vector2i = Vector2i(0, -1)

var new_direction: Vector2i
var new_coordinates: Vector2i

const walk_animation_name := "walk"
const turn_animation_name := "turn"

## "IDLE", "WALKING" or "TURNING"
const IDLE_STATE := "IDLE"
const WALKING_STATE := "WALKING"
const TURNING_STATE := "TURNING"
var movement_state := IDLE_STATE

## this property is driven by the AnimationPlayer
## the starting value is always 0.0, the end value is 1.0 and indicates animation end
##
## TODO: rewrite using Transform3D ?
@export var blend_value: float = 0.0:
	set(newValue):
		print("setter called, {0}".format([newValue]))
		if newValue == blend_value:
			return
		# assert(movement_state != IDLE_STATE)
		blend_value = newValue
		if movement_state == WALKING_STATE:
			var startPos := coord_to_position(coordinates)
			var endPos := coord_to_position(new_coordinates)
			position = (1.0 - blend_value) * startPos + blend_value * endPos
		elif movement_state == TURNING_STATE:
			var startRot := dir_to_rotation(direction)
			var endRot := dir_to_rotation(new_direction)
			# candidate rotations for the end
			var endRots := [endRot, endRot + Vector3(0, 2 * PI, 0), endRot - Vector3(0, 2 * PI, 0)]
			# select end rotation that is closest to the starting one from endRots
			endRot = endRots[0]
			endRot = endRots[1] if (endRots[1] - startRot).abs() < (endRot - startRot).abs() else endRot
			endRot = endRots[2] if (endRots[2] - startRot).abs() < (endRot - startRot).abs() else endRot
			rotation = (1.0 - blend_value) * startRot + blend_value * endRot

func coord_to_position(c: Vector2i) -> Vector3:
	return Vector3(c.x * 2 + 0.5, position.y, c.y * 2 + 0.5)
	
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
	
func apply_direction():
	blend_value = 0.0
	movement_state = TURNING_STATE
	animation_player.play(turn_animation_name)

func _input(event):
	## for now, we ignore any movement commands if we are in the middle of an animation
	## TODO: implement command queue
	if movement_state != IDLE_STATE:
		return

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
		new_direction = newDirection
		apply_direction()
		
	if isDestinationChange:
		if wall_tester.is_a_wall(destination.x, destination.y):
			return
		new_coordinates = destination
		apply_coordinates()
	
func _process(delta):
	pass

func _on_animation_player_animation_finished(anim_name):
	if anim_name == walk_animation_name:
		# finish current movement command and reset blend value
		assert(movement_state == WALKING_STATE)
		coordinates = new_coordinates
		movement_state = IDLE_STATE
		blend_value = 0.0
		position = coord_to_position(coordinates)
		return
	elif anim_name == turn_animation_name:
		assert(movement_state == TURNING_STATE)
		direction = new_direction
		movement_state = IDLE_STATE
		blend_value = 0.0
		rotation = dir_to_rotation(direction)
		return
	# TODO: finish other animations as well
	assert(false, "Unreachable location reached")
