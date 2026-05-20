@tool
class_name Joystick3dRepresentation
extends Node

@export var base_joystick_cartesian_plan:Node3D
@export var joystick_head_point:Node3D
@export var middle_stick:Node3D
@export var use_clamp:bool

@export var joystick_head_radius:float = 0.1:
	set(value):
		joystick_head_radius = value
		_refresh_3d_points()
@export var joystick_middle_radius:float = 0.1:
	set(value):
		joystick_middle_radius = value
		_refresh_3d_points()
@export var joystick_height:float = 0.1:
	set(value):
		joystick_height = value
		_refresh_3d_points()
@export var joystick_angle_space:float = 40
	
@export var joystick_value:Vector2:
	set(value):
		if use_clamp:
			value.x = clamp(value.x, -1, 1)
			value.y = clamp(value.y, -1, 1)
		joystick_value = value
		_refresh_3d_points()



func set_joystick_value(value: Vector2) -> void:
	joystick_value = value


func _refresh_3d_points() -> void:
	if base_joystick_cartesian_plan == null or joystick_head_point == null:
		return
	
	var euler_angle_forward : Vector3 = Vector3(-joystick_value.y * joystick_angle_space,0, -joystick_value.x * joystick_angle_space)
	var euler_angle_forward_in_radian := Vector3(deg_to_rad(euler_angle_forward.x), deg_to_rad(euler_angle_forward.y), deg_to_rad(euler_angle_forward.z))
	var quaternion_euler_angle_forward : Quaternion = Quaternion.from_euler(euler_angle_forward_in_radian)
	var position_local : Vector3 = quaternion_euler_angle_forward * Vector3.UP
	var position_local_with_distance : Vector3 = position_local * joystick_height

	var base_rotation_global : Quaternion = Quaternion.from_euler(base_joystick_cartesian_plan.global_rotation)
	var position_rotate_to_base : Vector3 = base_rotation_global * position_local_with_distance
	joystick_head_point.global_position = base_joystick_cartesian_plan.global_position + position_rotate_to_base

	if middle_stick != null:
		var start = base_joystick_cartesian_plan.global_position
		var end = joystick_head_point.global_position
		middle_stick.global_position = (start + end) * 0.5
		var direction = (end - start).normalized()
		middle_stick.look_at(middle_stick.global_position + direction, Vector3.UP)
		middle_stick.scale = Vector3(joystick_middle_radius, joystick_middle_radius,(end - start).length() )

		if joystick_head_point:
			joystick_head_point.scale = Vector3(joystick_head_radius, joystick_head_radius, joystick_head_radius)
