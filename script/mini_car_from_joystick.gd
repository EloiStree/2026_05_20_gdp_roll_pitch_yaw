extends CharacterBody3D
class_name MiniCarFromJoystick

# Designer exposed variables
@export var move_speed_in_ms: float = 0.2
@export var rotation_speed_angle: float = 90
@export var gravity: float = 0.2 

# Internal joystick input (-1..1 range recommended)
@export var joystick: Vector2 = Vector2.ZERO


func set_joystick(joystick_value: Vector2) -> void:
	# You can clamp or normalize here if needed
	self.joystick = joystick_value	


func _physics_process(delta: float) -> void:
	if abs(joystick.x) > 0.1: 
		rotate_y(-joystick.x * deg_to_rad(rotation_speed_angle)	 * delta)
	var forward_direction = -global_transform.basis.z  	
	var target_velocity = forward_direction * (joystick.y) * move_speed_in_ms	
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z	
	velocity.y = -gravity
	move_and_slide()
