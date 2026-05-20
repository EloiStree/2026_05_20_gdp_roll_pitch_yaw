class_name EulerRotationInDegree
extends Resource
@export var x_pitch_down_to_up_in_degree : float
@export var y_yaw_left_to_right_in_degree : float
@export var z_roll_left_to_right_in_degree : float

#
#func get_vector_in_degree() -> Vector3:
	#return Vector3(x_down_to_up_in_degree,y_left_to_right_in_degree,z_value_in_degree)
	#
#func get_vector_in_radian() -> Vector3:
	#return Vector3(deg_to_rad(x_down_to_up_in_degree),deg_to_rad(y_left_to_right_in_degree),deg_to_rad(z_value_in_degree))
#
#func get_to_quaternion() -> Quaternion:
	#return Quaternion.from_euler(Vector3(deg_to_rad(y_left_to_right_in_degree),deg_to_rad(x_down_to_up_in_degree),deg_to_rad(z_value_in_degree)))
