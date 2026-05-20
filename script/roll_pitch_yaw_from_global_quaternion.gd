class_name RollPitchYawFromNode3D
extends Node


signal on_x_pitch_degree_updated(angle_in_degrees:float)
signal on_y_roll_degree_updated(angle_in_degrees:float)
signal on_z_yaw_degree_updated(angle_in_degrees:float)

signal on_roll_pitch_degree_updated(x_pitch_in_degrees:float, z_roll_in_degrees:float)
signal on_joystick_simulation_updated(joystick:Vector2)
signal on_text_debug(value : String)


@export var direction_node: Node3D

@export var angle_range_to_generate_joystick : float = 50.0
@export var clamp_joystick_generated :bool=true


@export var use_debug_print: bool = false


@export var pitch_rotation_front_in_degrees_0_360_clockwise: float = 0.0
@export var roll_rotation_right_in_degrees_0_360_clockwise: float = 0.0

@export var percent_roll_right_01 : float = 0.0
@export var percent_pitch_front_01 : float = 0.0
@export var percent_roll_right_11 : float = 0.0
@export var percent_pitch_front_11 : float = 0.0

@export var pitch_degrees_180 :float = 0.0
@export var roll_degrees_180 :float = 0.0

@export var pitch_clamp_to_90_degrees: float = 0.0
@export var roll_clamp_to_90_degrees: float = 0.0





#region PITCH GET
func get_pitch_rotation_in_degrees_percent_11() -> float:
	return percent_pitch_front_11

func get_pitch_rotation_in_degrees_angle_left_rigth_180() -> float:
	return pitch_degrees_180

func get_pitch_rotation_in_degrees_angle_left_rigth_clamp_90() -> float:
	return pitch_clamp_to_90_degrees

func get_pitch_rotation_in_degrees_0_360() -> float:
	return pitch_rotation_front_in_degrees_0_360_clockwise
#endregion

#region ROLL GET
func get_roll_rotation_in_degrees_percent_11() -> float:
	return percent_roll_right_11

func get_roll_rotation_in_degrees_angle_left_rigth_180() -> float:
	return roll_degrees_180

func get_roll_rotation_in_degrees_angle_left_rigth_clamp_90() -> float:
	return roll_clamp_to_90_degrees

func get_roll_rotation_in_degrees_0_360() -> float:
	return roll_rotation_right_in_degrees_0_360_clockwise
#endregion







class PitchRollValues:
	var pitch_rotation_front_in_degrees_0_360_clockwise: float = 0.0
	var roll_rotation_right_in_degrees_0_360_clockwise: float = 0.0


static func get_pitch_raw_values_from_node(given_node: Node3D) -> PitchRollValues:
	return get_pitch_raw_values_from_global(Quaternion.from_euler(given_node.global_rotation))


static func get_pitch_raw_values_from_global( world_rotation_forward: Quaternion) -> PitchRollValues:
	
	var center:Vector3 = Vector3.ZERO
	var world_up = Vector3.UP
	
	var q_node_forward = world_rotation_forward
	var q_node_up = q_node_forward * Quaternion.from_euler(Vector3(deg_to_rad(90),0,0))
	var q_node_right = q_node_forward * Quaternion.from_euler(Vector3(0,deg_to_rad(-90),0))
	var v_forward = q_node_forward*Vector3(0,0,-1)
	var v_node_right = q_node_right*Vector3(0,0,-1)
	var v_node_up = q_node_up*Vector3(0,0,-1)
	var v_node_flat_forward = Vector3(v_forward.x,0,v_forward.z)
	var v_node_flat_right = Vector3(v_node_right.x,0,v_node_right.z)

	# https://godotengine.org/asset-library/asset/1766
	# DebugDraw3D.draw_line(center,world_up, Color.RED)
	# DebugDraw3D.draw_line(center,v_forward, Color.BLUE)
	# DebugDraw3D.draw_line(center,v_node_right, Color.RED)
	# DebugDraw3D.draw_line(center,v_node_up, Color.GREEN)
	# DebugDraw3D.draw_line(center,v_node_flat_right, Color.RED*0.5)
	# DebugDraw3D.draw_line(center,v_node_flat_forward, Color.BLUE*0.5)

		
	var is_facing_up = v_node_up.dot(world_up) > 0
	var is_facing_down = not is_facing_up

 ## COMPUTE THE RAW RIGHT CLOCKWISE ANGLE
	var opposed = distance(v_node_flat_right, v_node_right)
	var hypothenuse= distance(center, v_node_right)
	var adjacent = distance(center, v_node_flat_right)
	var clock_wise_angle = acos(clamp(adjacent / hypothenuse, -1.0, 1.0))
	var clock_wise_angle_degrees = rad_to_deg(clock_wise_angle)

	var trigo_angle_raw =clock_wise_angle_degrees
	var is_downward = sign(v_node_right.y- v_node_flat_right.y) < 0
	var is_upward = sign(v_node_right.y- v_node_flat_right.y) >= 0

	if is_facing_up and not is_downward:
		trigo_angle_raw = clock_wise_angle_degrees
	if is_facing_down and is_downward:
		trigo_angle_raw = 180.0-clock_wise_angle_degrees
	if is_facing_down and is_upward:
		trigo_angle_raw = 180.0+clock_wise_angle_degrees
	if is_facing_up and is_upward:
		trigo_angle_raw = 360.0-clock_wise_angle_degrees

## COMPUTE 	THE TILT CLOCKWISE ANGLE
	opposed = distance(v_node_flat_forward, v_forward)
	hypothenuse= distance(center, v_forward)
	adjacent = distance(center, v_node_flat_forward)
	var tilt_clock_wise_angle = acos(clamp(adjacent / hypothenuse, -1.0, 1.0))
	var tilt_clock_wise_angle_degrees = rad_to_deg(tilt_clock_wise_angle)

	var trigo_angle_tilt = tilt_clock_wise_angle_degrees
	is_downward = sign(v_forward.y- v_node_flat_forward.y) < 0
	is_upward = sign(v_forward.y- v_node_flat_forward.y) >= 0
	if is_facing_up and not is_downward:
		trigo_angle_tilt = tilt_clock_wise_angle_degrees
	if is_facing_down and is_downward:
		trigo_angle_tilt = 180.0-tilt_clock_wise_angle_degrees
	if is_facing_down and is_upward:
		trigo_angle_tilt = 180.0+tilt_clock_wise_angle_degrees
	if is_facing_up and is_upward:
		trigo_angle_tilt = 360.0-tilt_clock_wise_angle_degrees

	var result: PitchRollValues = PitchRollValues.new()
	result.pitch_rotation_front_in_degrees_0_360_clockwise = trigo_angle_tilt
	result.roll_rotation_right_in_degrees_0_360_clockwise = trigo_angle_raw
	return result



func _process(_delta: float) -> void:

	var pitch_raw_values = get_pitch_raw_values_from_node(direction_node)
	pitch_rotation_front_in_degrees_0_360_clockwise = pitch_raw_values.pitch_rotation_front_in_degrees_0_360_clockwise
	roll_rotation_right_in_degrees_0_360_clockwise = pitch_raw_values.roll_rotation_right_in_degrees_0_360_clockwise

	# from 0-360 to -180 to 180
	pitch_degrees_180 = fmod(pitch_rotation_front_in_degrees_0_360_clockwise + 180.0, 360.0) - 180.0
	roll_degrees_180 = fmod(roll_rotation_right_in_degrees_0_360_clockwise + 180.0, 360.0) - 180.0 

	# print ("Pitch Degrees: ", pitch_rotation_front_in_degrees_0_360_clockwise, " Raw: ", roll_rotation_right_in_degrees_0_360_clockwise)
	# print("180 Pitch Degrees: ", pitch_degrees_180, " 180 Raw Degrees: ", roll_degrees_180)

	percent_pitch_front_01 = (pitch_rotation_front_in_degrees_0_360_clockwise) / 360.0 
	percent_roll_right_01 = (roll_rotation_right_in_degrees_0_360_clockwise) / 360.0 
	percent_roll_right_11 = roll_degrees_180 /180.0
	percent_pitch_front_11 = pitch_degrees_180 /180.0

	pitch_clamp_to_90_degrees = clamp(pitch_degrees_180, -90.0, 90.0)
	roll_clamp_to_90_degrees = clamp(roll_degrees_180, -90.0, 90.0)


	var joystick := Vector2( roll_degrees_180,pitch_degrees_180)/angle_range_to_generate_joystick
	if clamp_joystick_generated:
		joystick.x = clamp(joystick.x, -1.0, 1.0)
		joystick.y = clamp(joystick.y, -1.0, 1.0)

	on_x_pitch_degree_updated.emit(pitch_degrees_180)
	on_y_roll_degree_updated.emit(roll_degrees_180)
	on_roll_pitch_degree_updated.emit(pitch_degrees_180, roll_degrees_180)
	on_joystick_simulation_updated.emit(joystick)

	var debug_text ="""
	ROLL X: %0.2f / %0.2f 
	PITCH Z: %0.2f / %0.2f 
	JOYSTICK: %0.2f,%0.2f
	""" % [
	   roll_degrees_180,
	   percent_roll_right_11,
		pitch_degrees_180,
		percent_pitch_front_11,
		  joystick.x,
		   joystick.y]
	
	on_text_debug.emit(debug_text)

	
	
@export var joystick:Vector2

static func distance(point_a: Vector3, point_b: Vector3) -> float:
	return (point_b - point_a).length()


func inverse_rotation_from_direction_to_forward_vector(direction: Vector3) -> Quaternion:
	var forward = Vector3(0, 0, -1)
	return quaternion_from_two_directions(forward, direction)


func quaternion_from_two_directions(from_direction: Vector3, to_direction: Vector3) -> Quaternion:
	var from_normalized = from_direction.normalized()
	var to_normalized = to_direction.normalized()

	var dot_product = from_normalized.dot(to_normalized)

	if dot_product > 0.999999:
		return Quaternion.IDENTITY

	elif dot_product < -0.999999:
		var orthogonal_vector = Vector3(1, 0, 0).cross(from_normalized)
		if orthogonal_vector.length() < 0.000001:
			orthogonal_vector = Vector3(0, 1, 0).cross(from_normalized)

		orthogonal_vector = orthogonal_vector.normalized()
		return Quaternion(orthogonal_vector.x, orthogonal_vector.y, orthogonal_vector.z, 0)

	else:
		var cross_product = from_normalized.cross(to_normalized)
		return Quaternion(
			cross_product.x,
			cross_product.y,
			cross_product.z,
			1.0 + dot_product
		).normalized()


func convert_quaternion_to_forward_vector(quaternion: Quaternion) -> Vector3:
	var forward = Vector3(0, 0, -1)
	return quaternion * forward
