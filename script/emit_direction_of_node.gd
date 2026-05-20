class_name EmitDirectionOfNode
extends Node

signal on_global_direction_emit(direction: Vector3)

enum DirectionType{
	UnityZ,
	GodotZ,
	GodotY,
	GodotX
}

## What node should we use to emit direction
@export var node_to_observe:Node3D
## What direction should we use ? UP, FRONT, RIGHT
@export var direction_type :DirectionType

@export var last_direction_debug:Vector3

func _process(delta: float) -> void:
	var direction =Vector3(0, 0, -1)
	if direction_type== DirectionType.UnityZ:
		direction = -node_to_observe.global_transform.basis.z
	elif direction_type== DirectionType.GodotZ:
		direction = node_to_observe.global_transform.basis.z
	elif direction_type== DirectionType.GodotY:
		direction = node_to_observe.global_transform.basis.y
	elif direction_type== DirectionType.GodotX:
		direction = node_to_observe.global_transform.basis.x

	last_direction_debug = direction
	on_global_direction_emit.emit(direction)
