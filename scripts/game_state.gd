## This class is a central place for most of data that represents the state of the
## game world. Most means that there are some exceptions of course; if you are unsure if X belongs here,
## ask yourself a question: "Do we need to write X into the save file?", if yes, than X most likely
## has to be put here as well.
##
## TODO: turn this into a Resource based class?
class_name GameState
extends RefCounted

var character_coordinates: Vector2i = Vector2i.ZERO:
	set(newValue):
		if character_coordinates == newValue:
			return
		character_coordinates = newValue
		print("my coordinate is {0}".format([character_coordinates]))
		character_position_changed.emit(newValue)
var character_direction: Vector2i = Vector2i(0, -1):
	set(newValue):
		if character_direction == newValue:
			return
		character_direction = newValue
		character_position_changed.emit(newValue)

signal character_position_changed(p: Vector2i)
signal character_direction_changed(d: Vector2i)
