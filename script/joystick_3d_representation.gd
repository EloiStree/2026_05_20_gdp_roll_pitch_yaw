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
	
	# Exemple compliqué pour rien.
	# Mais cela montre comment utiliser des rotations et des quaternions.
	# Le but est d'apprendre.


	## On calcule notre rotation avec Euler vers l'avant.
	var euler_angle_forward : Vector3 = Vector3(-joystick_value.y * joystick_angle_space,0, -joystick_value.x * joystick_angle_space)

	## Comme on a besoin de radians pour créer le quaternion, on le convertit.
	var euler_angle_forward_in_radian := Vector3(deg_to_rad(euler_angle_forward.x), deg_to_rad(euler_angle_forward.y), deg_to_rad(euler_angle_forward.z))

	## Créons donc notre angle de joystick sur Z (vers l'avant avec Euler).
	var quaternion_euler_angle_forward : Quaternion = Quaternion.from_euler(euler_angle_forward_in_radian)
	## Sauf que nous, c'est vers le dessus que nous le voulons.
	## Petit tour de magie : notre angle multiplié par le vecteur UP nous donne notre rotation.
	## Ici, toujours localement dans l'espace V(0, 0, 0).
	var position_local : Vector3 = quaternion_euler_angle_forward * Vector3.UP

	## On aimerait lui donner un peu de hauteur à notre point.
	## Pour cela, on peut multiplier un vecteur par une distance en float.
	var position_local_with_distance : Vector3 = position_local * joystick_height

	## On a calculé en zéro... Il faut préparer le fait de le tourner dans l'angle de notre destination.
	## Allons chercher le quaternion de notre base.
	var base_rotation_global : Quaternion = Quaternion.from_euler(base_joystick_cartesian_plan.global_rotation)
	## Un vecteur multiplié par un quaternion nous donne le point tourné par celui-ci.
	## Toujours en V(0, 0, 0), car on utilise une direction ici.
	var position_rotate_to_base : Vector3 = base_rotation_global * position_local_with_distance
	## Comme notre point est tourné par rapport à la rotation de notre base,
	## on peut le déplacer à la base en y ajoutant le vecteur de la base.
	joystick_head_point.global_position = base_joystick_cartesian_plan.global_position + position_rotate_to_base

	## Et voilà pour la tête du joystick sur sa base.

	## On aimerait un milieu dans un jeu où on ne peut pas scaler.

	if middle_stick != null:
		## On prend nos extrémités.
		var start = base_joystick_cartesian_plan.global_position
		var end = joystick_head_point.global_position
		## On récupère le milieu des deux.
		middle_stick.global_position = (start + end) * 0.5
		## On trouve la direction de la base vers la tête (destination - origine).
		var direction = (end - start).normalized()

		## Et on utilise la magie du look_at pour faire tourner notre cylindre vers la direction.
		## Sur un jeu qui se joue avec un axe global UP,
		## cela peut créer des bugs de rotation. Ce n'est pas parfait.
		middle_stick.look_at(middle_stick.global_position + direction, Vector3.UP)

		## Occupons-nous de scaler un peu notre point du milieu avec la longueur demandée
		## par le designer entre les deux points, en utilisant son radius.
		middle_stick.scale = Vector3(joystick_middle_radius, joystick_middle_radius,(end - start).length() )

		if joystick_head_point:
			## Un dernier scale de notre tête, et on est bon...
			joystick_head_point.scale = Vector3(joystick_head_radius, joystick_head_radius, joystick_head_radius)
	
	## Tadaam, vous avez un joystick qui bouge avec le Vector2 donné. 😋
