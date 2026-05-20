@tool
# This class takes a direction and converts it into joystick, yaw, pitch, and roll values.
class_name RollPitchYawFromDirectionUp
extends Node

signal on_pitch_x_updated(angle_in_degree_180 : float)
signal on_yaw_y_updated(angle_in_degree_180 : float)
signal on_roll_z_updated(angle_in_degree_180 : float)

signal on_roll_and_pitch_updated(roll_degree_180 : float, pitch_degree_180 : float)
signal on_joystick_updated(joystick : Vector2)
signal on_text_debug(value : String)

# When this direction changes, the script recalculates roll, pitch, yaw, and joystick values.
@export var local_direction : Vector3 :
	set(value):
		local_direction = value.normalized()
		_refresh()

# Optional debug node placed at the world origin to show the current direction.

# Used to convert roll and pitch angles into a joystick value.
# This value defines how much angle is needed to reach joystick strength 1.
# Example: 10 = very sensitive, 90 = larger tilt needed, 180 = almost full rotation needed.
@export var angle_range_to_generate_joystick : float = 50.0

# If true, the joystick values are limited between -1 and 1.
@export var use_clamp_of_percent_1_to_1 : bool = true
# If true, the values are recalculated every frame.
@export var use_process_to_refresh:bool=true


@export_group("Debug Zone")
@export var node_for_debug_at_zero : Node3D
@export var angle_x_roll : float = 0
@export var angle_y_yaw : float = 0
@export var angle_z_pitch : float = 0
@export var simulated_joystick : Vector2

func _process(delta : float) -> void:
	# Met à jour les valeurs à chaque frame quand l'actualisation automatique est activée.
	# C'est simple à utiliser, mais cela peut faire du travail inutile si rien n'a changé.
	if use_process_to_refresh:
		_refresh()


# Permet à un autre script de définir la direction locale à utiliser.
# La valeur doit représenter uniquement une direction depuis (0, 0, 0). L'avant est -Z.
func set_direction_to_generate_xyz_angles(given_direction : Vector3) : 
	local_direction = given_direction
	_refresh()

func _refresh() -> void:

	# Buts de ce calcul :
	# - produire un pitch et un roll entre -180 et 180 à partir de l'axe Y (haut) de la direction
	# - produire un yaw allant de la gauche vers la droite
	# - fournir une valeur de joystick pour simplifier la création de mini-jeux.


	# Si un nœud de debug est assigné, le placer sur la direction en zero.
	if node_for_debug_at_zero != null : 
		# La direction normalisée garde son orientation avec une longueur fixée à 1.
		node_for_debug_at_zero.global_position = local_direction


	# Calcule l'inclinaison latérale à partir des axes X (droite) et Y (haut).
	angle_x_roll = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.x,local_direction.y))
	
	# Calcule l'inclinaison vers l'avant avec les axes Y (haut) et Z (avant).
	angle_z_pitch = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.z,local_direction.y))

	# Calcule le yaw pour savoir si la direction pointe à droite ou à gauche.
	# Seuls les axes X et Z sont utilisés ici, sans tenir compte de la hauteur.
	angle_y_yaw = flat_plane_xy_to_up_angle_of_180_degrees(Vector2(local_direction.x,local_direction.z))

	# Transmet les angles calculés aux autres scripts via des signaux.
	on_pitch_x_updated.emit(angle_x_roll)
	on_yaw_y_updated.emit(angle_y_yaw)
	on_roll_z_updated.emit(angle_z_pitch)

	# Certains scripts peuvent avoir besoin du roll et du pitch ensemble.
	# Ce signal envoie les deux en même temps.
	on_roll_and_pitch_updated.emit(angle_z_pitch, angle_x_roll)
	
	# Convertit le roll et le pitch en une valeur de type joystick.
	# La plage d'angle définit à quelle vitesse le joystick atteint sa pleine intensité.
	simulated_joystick = Vector2(angle_x_roll,angle_z_pitch)/ angle_range_to_generate_joystick

	# Limite les valeurs du joystick à la plage habituelle de -1 à 1.
	if use_clamp_of_percent_1_to_1:
		simulated_joystick.x = clamp(simulated_joystick.x, -1, 1)
		simulated_joystick.y = clamp(simulated_joystick.y, -1, 1)

	# Envoie la valeur de joystick générée.
	on_joystick_updated.emit(simulated_joystick)

	# Construit un bloc de texte pour faciliter la lecture des valeurs d'entrée et de sortie actuelles.
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
	# Start by calculating the angle on the XY plane using only positive values.
	# abs() temporarily removes the sign so the base angle is easier to compute.
	# atan2 uses the two sides of the triangle to get the angle.
	# The variable names describe the role of each value.
	var adjacent_edge = abs(direction_xy.y)
	var opposed_edge = abs(direction_xy.x)

	# atan2 returns an angle in radians.
	var radian_angle_computed = atan2(adjacent_edge, opposed_edge)
	# Convert radians to degrees because they are easier to read and debug.
	var degree_angle_computed = rad_to_deg(radian_angle_computed)

	# Apply the X and Y signs again.
	# Each quadrant needs a different correction to keep the final angle correct.
	var x :float = direction_xy.x
	var y: float = direction_xy.y
	var angle = degree_angle_computed

	# Goal: up = 0, down = ±180.
	if x >= 0 and y >= 0 :
		# Top-right quadrant: shift the angle so it starts from the upward Y axis.
		angle = 90 - angle  
	elif x <= 0 and y >= 0 :
		# Top-left quadrant: continue the rotation toward the left.
		angle = angle - 90
	elif x >= 0 and y <= 0 :
		# Bottom-right quadrant: continue the rotation toward the bottom.
		angle = 90 + angle
	elif x <= 0 and y <= 0:
		# Bottom-left quadrant: mirror the angle into the last quadrant.
		angle = -90 - angle
	else :
		# If the vector is zero, return 0.
		angle = 0
	
	return angle
