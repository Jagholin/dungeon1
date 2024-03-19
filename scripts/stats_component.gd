class_name StatsComponent
extends Component

@export var initial_stats: Stats
var current_stats: Stats

func get_stats() -> Stats:
	return current_stats

func _ready():
	current_stats = initial_stats.duplicate()

func get_component_name() -> StringName:
	return &"StatsComponent"