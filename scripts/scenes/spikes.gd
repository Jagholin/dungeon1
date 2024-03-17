class_name Spikes
extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var grid_bound: GridBoundComponent = $GridBoundComponent

const activate_animation := "activate"
const deactivate_animation := "deactivate"

const HIDDEN_STATE := &"HIDDEN"
const ACTIVE_STATE := &"ACTIVE"
var state = "HIDDEN"

var hurting: bool = false

var time_elapsed := 0.0
var game_state: GameState

func player_is_standing() -> bool:
	return game_state.character_coordinates.x == grid_bound.grid_coordinate.x and \
		game_state.character_coordinates.y == grid_bound.grid_coordinate.z

func set_hurting():
	hurting = true
	# TODO: if the player is still here, make hurt.

func reset_hurting():
	hurting = false

func oops():
	print("oohps")

func on_movement_initiated():
	if hurting:
		oops()
	elif state == HIDDEN_STATE:
		var t := create_tween()
		t.tween_interval(0.76)
		t.tween_callback(apply_active)
	return MovementListenerComponent.MovementEffect.NONE
		
func apply_active():
	assert(state == HIDDEN_STATE)
	state = ACTIVE_STATE
	anim_player.play(activate_animation)

func apply_hidden():
	assert(state == ACTIVE_STATE)
	state = HIDDEN_STATE
	anim_player.play(deactivate_animation)

func _ready():
	game_state = Globals.get_app_node().game_state

func _process(delta):
	if hurting and player_is_standing():
		oops()
	if state == ACTIVE_STATE:
		if player_is_standing():
			time_elapsed = 0
		
		time_elapsed += delta
		if time_elapsed > 2:
			apply_hidden()
