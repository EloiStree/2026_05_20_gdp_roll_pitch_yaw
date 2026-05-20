@tool
## This class allow from a direction to generate a joystick signal and some yaw pitch roll value.
class_name RollPitchYawFromDirectionUp
extends Node

signal on_pitch_x_updated(angle_in_degree_180 : float)
signal on_yaw_y_updated(angle_in_degree_180 : float)
signal on_roll_z_updated(angle_in_degree_180 : float)

signal on_roll_and_pitch_updated(roll_degree_180 : float, pitch_degree_180 : float)
signal on_joystick_updated(joystick : Vector2)
signal on_text_debug(value : String)

## Change the direction will generate new roll, pitch, yaw and joystick values
@export var local_direction : Vector3 :
	set(value):
		local_direction = value
		_refresh()

## Give a Node to debug, it is going to be set in Godot Zero Center Point		

## Use to build a usefull joystick simulation from roll/pitch from angle
## It is the value to clamp and normalize the joystick values
## 10 Will give very ractive joystick when 90 will need you to turn full left right and 180 require to make a up to down rotation.
@export var angle_range_to_generate_joystick : float = 50.0

## Do you need to clamp the joystib between -1 and 1
@export var use_clamp_of_percent_1_to_1 : bool = true
## Do you need to refresh it all frame ?
@export var use_process_to_refresh:bool=true


@export_group("Debug Zone")
@export var node_for_debug_at_zero : Node3D
@export var angle_x_roll : float = 0
@export var angle_y_yaw : float = 0
@export var angle_z_pitch : float = 0
@export var simulated_joystick : Vector2

func _process(delta : float) -> void:
	##🐿️ Allows to ensure that the value is updated
	## But use a bit of process for nothing.
	if use_process_to_refresh:
		_refresh()


## Allows designer and developer to give the local direction to use
## Must be a direction (starting at Vector(0,0,0) ). Forward is in Unity -Z
func set_direction_to_generate_xyz_angles(given_direction : Vector3) : 
	local_direction = given_direction
	_refresh()

func _refresh() -> void:
	## If designer gave a node to debug a the Zero coordinate
	if node_for_debug_at_zero != null : 
		## We display the Node3D at the direction with a magnitude of 1
		node_for_debug_at_zero.global_position = local_direction.normalized()


	# In class
	# angle_x_roll = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.x,local_direction.y))
	# angle_y_yaw = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.x,-local_direction.z))
	# angle_z_pitch = -flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.z,local_direction.y))
	
	#Grok
	angle_x_roll = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.x,local_direction.y))
	angle_y_yaw = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.x,-local_direction.z))
	angle_z_pitch = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.z,local_direction.y))

	##	We send to the other developer the compute angles
	on_pitch_x_updated.emit(angle_x_roll)
	on_yaw_y_updated.emit(angle_y_yaw)
	on_roll_z_updated.emit(angle_z_pitch)

	# Lots of change that some developer will need pitch and roll
	# So a special signal for them.
	on_roll_and_pitch_updated.emit(angle_z_pitch, angle_x_roll)
	
	# We need for our game to move a small car from a joystick.
	# Let's turn a direction to a joystick value.
	# Roll and pitch / by designer clamping value give this joystick/
	simulated_joystick = Vector2(angle_x_roll,angle_z_pitch)/ angle_range_to_generate_joystick

	## If the designer dont want 2.4 or 5.1 percent but -1 to 1
	if use_clamp_of_percent_1_to_1:
		simulated_joystick.x = clamp(simulated_joystick.x, -1, 1)
		simulated_joystick.y = clamp(simulated_joystick.y, -1, 1)

	# Lets send the joystick we build to the developer and designer.
	on_joystick_updated.emit(simulated_joystick)

	# We may want to debug the values we received and produced
	var debug_text ="""
	DIR: %0.2f,%0.2f,%0.2f,
	ROLL X: %0.2f
	PITCH Z: %0.2f
	YAW Y: %0.2f
	JOYSTICK: %0.2f,%0.2f
	""" % [local_direction.x,
	 local_direction.y,
	  local_direction.z,
	   angle_x_roll,
		angle_z_pitch,
		 angle_y_yaw,
		  simulated_joystick.x,
		   simulated_joystick.y]
	
	on_text_debug.emit(debug_text)
	
func flat_plane_xy_to_up_angle_of_180_degrees(direction_xy : Vector2) -> float:

	var adjacent_edge = abs(direction_xy.y)
	var opposed_edge = abs(direction_xy.x)
	var radian_angle_computed = atan2(adjacent_edge, opposed_edge)
	var degree_angle_computed = rad_to_deg(radian_angle_computed)
	var x :float = direction_xy.x
	var y: float = direction_xy.y
	var angle = degree_angle_computed

	if x >= 0 and y >= 0 :
		# TOP LEFT OF THE TRIGONO OFSET
		angle = 90 - angle  
	elif x <= 0 and y >= 0 :
		# TOP RIGHT OF THE TRIGONO OFSET
		angle = angle - 90
	elif x >= 0 and y <= 0 :
		# BOTTOM LEFT OF THE TRIGONO OFSET
		angle = 90 + angle
	elif x <= 0 and y <= 0:
		# BOTTOM RIGHT OF THE TRIGONO OFSET
		angle = -90 - angle
	else :
		# EXCEPTION CASE
		angle = 0
	
	return angle


## Apparently what we did it good to learn trigonometry...
## But in relality we alreayd have the good angle ?
func grok_flat_plane_xy_to_up_angle_of_180_degrees(direction_xy: Vector2) -> float:
	"""
	Returns angle in degrees:
		0°   = Up (+Y)
	   90°   = Right (+X)
	  180°   = Down (-Y)
	  -90°   = Left (-X)
	Range: -180 to +180
	"""
	if direction_xy.is_zero_approx():
		return 0.0
	
	# atan2(x, y) gives exactly the desired convention when 0° is Up
	return rad_to_deg(atan2(direction_xy.x, direction_xy.y))
