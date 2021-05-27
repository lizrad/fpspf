extends CharacterBase
class_name Player

var drag := Constants.move_drag
var move_acceleration := Constants.move_acceleration

export(float) var inner_deadzone := 0.2
export(float) var outer_deadzone := 0.8

var ranged_attack_type := Constants.ranged_attack_type
var melee_attack_type := Constants.melee_attack_type

# Dashing
var time_since_dash_start := 0.0
var initial_dash_burst := Constants.dash_impulse
var dash_exponent := Constants.dash_exponent
var dash_cooldown := 1.0

signal died

# TODO: Consider giving this an initial size -- it'll probably hold over 1000 entries
var movement_records = []

var velocity := Vector3.ZERO
var current_target_velocity := Vector3.ZERO

onready var _player_hud : PlayerHUD = get_node("CameraManager/ViewCamera/ViewportContainer/PlayerHUD")


class MovementFrame extends Spatial:
	var attack_type
	
	func _init(initial_transform, initial_attack_type):
		self.transform = initial_transform
		self.attack_type = initial_attack_type

func _ready():
	$Attacker.set_bullet_range(ranged_attack_type.attack_range)

func _physics_process(delta):
	if not visible:
		return
	
	var input = get_normalized_input("player_move", inner_deadzone, outer_deadzone)
	var movement_input_vector = Vector3(input.y, 0.0, -input.x)
	
	if Input.is_action_pressed("player_dash_" + str(id)):
		var e_section = max(
			exp(log(initial_dash_burst - 1 / dash_exponent * time_since_dash_start)),
			0.0
		)
		velocity += movement_input_vector * e_section
		time_since_dash_start += delta
	else:
		if time_since_dash_start > dash_cooldown:
			time_since_dash_start = 0.0
		elif time_since_dash_start != 0.0:
			time_since_dash_start += delta
	var progress = time_since_dash_start / dash_cooldown
	_player_hud.set_dash_progress(1.0 if progress == 0.0 else progress)
	apply_acceleration(movement_input_vector * move_acceleration)
	move_and_slide(velocity)
	
	var rotate_input = get_normalized_input("player_look", 1.0, 0.0, 0.5)
	var rotate_input_vector = Vector3(rotate_input.y, 0.0, -rotate_input.x)
	
	if rotate_input_vector != Vector3.ZERO:
		look_at(rotate_input_vector + global_transform.origin, Vector3.UP)
	
	var attack_type = null
	if Input.is_action_pressed("player_shoot_" + str(id)):
		attack_type = ranged_attack_type
	
	if Input.is_action_pressed("player_melee_" + str(id)):
		attack_type = melee_attack_type
		
	if attack_type:
		if not $Attacker.attack(attack_type, self):
			attack_type = null
	# TODO: add melee record
	movement_records.append(MovementFrame.new(global_transform, attack_type))


func get_id():
	return id

func set_id(new_id):
	id = new_id
	set_rendering_for_character_id(id)


func set_rendering_for_character_id(id):
	.set_rendering_for_character_id(id)
	$CameraManager/ViewCamera/ViewportContainer/Viewport/Camera.cull_mask = 1 + 2 + pow(2, 5 + id)
	$CameraManager/LightCamera/Viewport/Camera.cull_mask = 1 + pow(2, 5 + id)


func get_visibility_mask():
	return get_node("CameraManager/LightCamera/Viewport").get_texture()


func get_normalized_input(type, outer_deadzone, inner_deadzone, min_length = 0.0):
	var id_string = "_" + str(id)
	var input = Vector2(Input.get_action_strength(type + "_up" + id_string) - 
						Input.get_action_strength(type + "_down" + id_string),
						Input.get_action_strength(type + "_right" + id_string) - 
						Input.get_action_strength(type + "_left" + id_string))
	
	# Remove signs to reduce the number of cases
	var signs = Vector2(sign(input.x), sign(input.y))
	input = Vector2(abs(input.x), abs(input.y))
	
	if input.length() < min_length:
		return Vector2.ZERO
	
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


func receive_damage(damage: float):
	print("Player received damage: ", damage)
	if invincible:
		print("	but is invincible!")
		return

	set_current_health(_current_health - damage)
	
	if _current_health <= 0:
		print("	-> Player dead")
		emit_signal("died")


func reset():
	movement_records = []
	transform.origin = Vector3.ZERO
	set_current_health(Constants.max_health)


func _on_light_cone_entered(body: Node):
	if body is Ghost:
		body.visible = true


func _on_light_cone_exited(body: Node):
	if body is Ghost:
		body.visible = false
