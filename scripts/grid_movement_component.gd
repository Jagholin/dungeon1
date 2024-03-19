class_name GridMovementComponent
extends GridDirectionalComponent

const GM_COMPONENT_NAME := &"GridMovementComponent"

@export var animation_player: AnimationPlayer
@export var step_sound_player: AudioStreamPlayer
# @export var level: Level
@export var movement_listeners_can_interrupt: bool = false
@export var warn_on_movement_listener_interruption: bool = false

func get_component_name() -> StringName:
	return GM_COMPONENT_NAME

func get_component_names() -> Array[StringName]:
	var temp := super.get_component_names()
	temp.push_back(GM_COMPONENT_NAME)
	return temp

var new_direction: Vector3i
var new_coordinates: Vector3i

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

var movement_listeners: Array[MovementListenerComponent] = []

func add_movement_listener(listener: MovementListenerComponent):
	movement_listeners.push_back(listener)
func remove_movement_listener(listener: MovementListenerComponent):
	movement_listeners.remove_at(movement_listeners.find(listener))

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
			var startPos: Vector3 = target.coord_to_position(grid_coordinate)
			var endPos: Vector3 = target.coord_to_position(new_coordinates)
			target.position = (1.0 - blend_value) * startPos + blend_value * endPos
		elif movement_state == TURNING_STATE:
			var startRot: Vector3 = target.dir_to_rotation(grid_direction)
			var endRot: Vector3 = target.dir_to_rotation(new_direction)
			# candidate rotations for the end
			var endRots := [endRot, endRot + Vector3(0, 2 * PI, 0), endRot - Vector3(0, 2 * PI, 0)]
			# select end rotation that is closest to the starting one from endRots
			endRot = endRots[0]
			endRot = endRots[1] if (endRots[1] - startRot).abs() < (endRot - startRot).abs() else endRot
			endRot = endRots[2] if (endRots[2] - startRot).abs() < (endRot - startRot).abs() else endRot
			target.rotation = (1.0 - blend_value) * startRot + blend_value * endRot

func apply_coordinates():
	blend_value = 0.0
	movement_state = WALKING_STATE
	animation_player.play(walk_animation_name)
	if step_sound_player:
		step_sound_player.play()
	
func apply_direction():
	blend_value = 0.0
	movement_state = TURNING_STATE
	animation_player.play(turn_animation_name)
	if step_sound_player:
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
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == walk_animation_name:
		# finish current movement command and reset blend value
		assert(movement_state == WALKING_STATE)
		grid_coordinate = new_coordinates
		movement_state = IDLE_STATE
		blend_value = 0.0
		target.position = target.coord_to_position(new_coordinates)
		return
	elif anim_name == turn_animation_name:
		assert(movement_state == TURNING_STATE)
		grid_direction = new_direction
		movement_state = IDLE_STATE
		blend_value = 0.0
		target.rotation = target.dir_to_rotation(new_direction)
		return
	elif anim_name == wall_animation_name:
		assert(movement_state == WALL_BUMP_STATE)
		movement_state = IDLE_STATE
		blend_value = 0.0
		return
	# TODO: finish other animations as well
	assert(false, "Unreachable location reached")

func _move_to_destination(dest: Vector3i):
	if Globals.get_current_level().is_a_wall(dest):
		new_coordinates = dest
		apply_wall_bump()
		return

	if movement_listeners_can_interrupt:
		for ml in movement_listeners:
			if ml.on_movement_initiated(dest) == MovementListenerComponent.MovementEffect.PREVENT_MOVEMENT:
				if warn_on_movement_listener_interruption:
					push_warning("The movement was blocked by a movement listener")
				apply_cooldown()
				return

	new_coordinates = dest
	apply_coordinates()

func move_forward():
	var dest := grid_coordinate + grid_direction
	_move_to_destination(dest)

func move_backward():
	var dest := grid_coordinate - grid_direction
	_move_to_destination(dest)

func rotate_left():
	new_direction = Vector3i(grid_direction.z, 0, -grid_direction.x)
	apply_direction()

func rotate_right():
	new_direction = Vector3i(-grid_direction.z, 0, grid_direction.x)
	apply_direction()

func strafe_left():
	var dir := Vector3i(grid_direction.z, 0, -grid_direction.x)
	var dest := grid_coordinate + dir
	_move_to_destination(dest)

func strafe_right():
	var dir := Vector3i(-grid_direction.z, 0, grid_direction.x)
	var dest := grid_coordinate + dir
	_move_to_destination(dest)
