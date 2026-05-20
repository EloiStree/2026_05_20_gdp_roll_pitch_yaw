class_name PointDirectionFromNode
extends Node

signal direction_updated(direction_from_node : Vector3)

@export var cartesian_plan : Node3D
@export var track_point : Node3D
@export var debug_point : Node3D

func _process(delta: float) -> void:
	var local_point = track_point.global_position - cartesian_plan.global_position
	var global_quaternion = Quaternion.from_euler(cartesian_plan.global_rotation).inverse()
	var rotate_local_point = global_quaternion * local_point
	if debug_point:
		debug_point.global_position = rotate_local_point
	rotate_local_point.z *= -1
	direction_updated.emit(rotate_local_point)
