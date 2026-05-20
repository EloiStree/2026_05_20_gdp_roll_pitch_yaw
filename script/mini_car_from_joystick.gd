


extends CharacterBody3D

## Rapide code d une voiture  pour tester les joysticks que l on creer depuis les rotations.
class_name MiniCarFromJoystick

@export var move_speed_in_ms: float = 0.2
@export var rotation_speed_angle: float = 90
@export var gravity: float = 0.2 

@export var joystick: Vector2 = Vector2.ZERO


## Expect a joystick from -1 to 1 in X Yup
func set_joystick(joystick_value: Vector2) -> void:
	joystick_value.x = clamp(joystick_value.x, -1, 1)
	joystick_value.y = clamp(joystick_value.y, -1, 1)
	self.joystick = joystick_value	
	


func _physics_process(delta: float) -> void:
	## On tourne sur le Y du character avec le temps qui passe par frame (delta)
	# Attention le rotation sont en radian et pas en degrees.
	if abs(joystick.x) > 0.1: 
		rotate_y(-joystick.x * deg_to_rad(rotation_speed_angle)	 * delta)

	# Le Z de godot est inverse du Z de Unity que l on utilise nous.
	var forward_direction = -global_transform.basis.z  	
	## On utilise la vitesse et le joystick pour donner la direction
	var target_velocity = forward_direction * (joystick.y) * move_speed_in_ms	
	## On donne les informations a velocity pour bouger le character
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z	
	velocity.y = -gravity

	## on demande au code d être calculer.
	move_and_slide()
