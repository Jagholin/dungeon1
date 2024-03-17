class_name Component
extends Node3D

var target: Node3D

func _notification(what):
    if what == NOTIFICATION_PARENTED:
        target = get_parent()

func get_target_3d() -> Node3D:
    return target as Node3D
