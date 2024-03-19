class_name StatsComponent
extends Component

const STATS_COMPONENT_NAME := &"StatsComponent"

@export var initial_stats: Stats
var current_stats: Stats

func get_stats() -> Stats:
	return current_stats

func _ready():
	current_stats = initial_stats.duplicate()

func get_component_name() -> StringName:
	return STATS_COMPONENT_NAME

func get_component_names() -> Array[StringName]:
	var temp := super.get_component_names()
	temp.push_back(STATS_COMPONENT_NAME)
	return temp
