extends KinematicBody
class_name Player

export(float) var drag := 0.2
export(float) var move_acceleration := 1.5

export(float) var inner_deadzone := 0.2
export(float) var outer_deadzone := 0.8

# TODO: Consider giving this an initial size -- it'll probably hold over 1000 entries
var movement_records = []

var velocity := Vector3.ZERO
var current_target_velocity := Vector3.ZERO
var id: int


class MovementFrame extends Spatial:
	var is_shooting
	
	func _init(initial_transform, initial_shooting):
		self.transform = initial_transform
		self.is_shooting = initial_shooting


func get_normalized_input(type):
	var id_string = "_" + str(id)
	var input = Vector2(Input.get_action_strength(type + "_up" + id_string) - 
						Input.get_action_strength(type + "_down" + id_string),
						Input.get_action_strength(type + "_right" + id_string) - 
						Input.get_action_strength(type + "_left" + id_string))
	
	# Remove signs to reduce the number of cases
	var signs = Vector2(sign(input.x), sign(input.y))
	input = Vector2(abs(input.x), abs(input.y))
	
	# Deazones for each axis
	if input.x > outer_deadzone:
		input.x = 1.0
	elif input.x < inner_deadzone:
		input.x = 0.0
	else:
		input.x = inverse_lerp(inner_deadzone, outer_deadzone, input.x)
		
	if input.y > outer_deadzone:
		input.y = 1.0
	elif input.y < inner_deadzone:
		input.y = 0.0
	else:
		input.y = inverse_lerp(inner_deadzone, outer_deadzone, input.y)
		
	# Re-apply signs
	input *= signs
	
	# Limit at length 1
	if input.length() > 1.0:
		input /= input.length()
	
	return input


func apply_acceleration(acceleration):
	# First drag, then add the new acceleration
	# For drag: Lerp towards the target velocity
	# This is usually 0, unless we're on something that's moving, in which case it is that object's
	#  velocity
	velocity = lerp(velocity, current_target_velocity, drag)
	velocity += acceleration


func _physics_process(delta):
	var input = get_normalized_input("player_move")
	var movement_input_vector = Vector3(input.y, 0.0, -input.x)
	
	apply_acceleration(movement_input_vector * move_acceleration)
	move_and_slide(velocity)
	
	var rotate_input = get_normalized_input("player_look")
	var rotate_input_vector = Vector3(rotate_input.y, 0.0, -rotate_input.x)
	
	if rotate_input_vector != Vector3.ZERO:
		look_at(rotate_input_vector + global_transform.origin, Vector3.UP)
	
	var is_shooting = false
	if Input.is_action_pressed("player_shoot_" + str(id)):
		is_shooting = true
		$Shooter.Shoot()
	
	movement_records.append(MovementFrame.new(global_transform, is_shooting))


func reset():
	movement_records = []
	transform.origin = Vector3.ZERO
