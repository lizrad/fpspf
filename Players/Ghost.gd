extends CharacterBase
class_name Ghost

var movement_record := []

var _frame_timer: float = 0.0
var current_frame : int = 0

var max_health : int = 3
var current_health : int = 3

var died_at_frame : int = INF

var _time_scale := 1.0

signal died


func _ready():
	set_rendering_for_character_id(CharacterID.GHOST)

	
func set_time_scale(time_scale: float) -> void:
	_time_scale = time_scale

func _physics_process(delta):
	_frame_timer += delta*abs(_time_scale);
	while _frame_timer>=delta :
		_frame_timer -= delta
		current_frame += (sign(_time_scale)*1)
	
	if _time_scale>=0:
		if current_frame < movement_record.size():
			var frame = movement_record[current_frame]
			global_transform = frame.transform
			if frame.attack_type:
				$Attacker.attack(frame.attack_type, self)
	else :
		if current_frame>=0:
			if current_frame > died_at_frame or current_frame>=movement_record.size():
				_showDead()
			else:
				_showAlive()
				var frame = movement_record[current_frame]
				global_transform = frame.transform
				if frame.attack_type:
					$Attacker.attack(frame.attack_type, self)
					

func receive_damage(damage: float):
	print("Ghost received damage: ", damage)
	current_health -= damage
	
	if current_health <= 0:
		died_at_frame = current_frame
		print(" -> Ghost dead")
		emit_signal("died")
		_showDead()


func reset(start_frame : int) -> void:
	current_frame = start_frame
	_frame_timer = 0.0
	_showAlive()
	_set_initial_position()
	current_health = max_health


func _set_initial_position() -> void:
	var start_frame = current_frame if current_frame < movement_record.size() else movement_record.size()-1
	global_transform = movement_record[start_frame].transform
	
func _showDead():
	rotation.z = PI / 2
	#set_physics_process(false)
	$CollisionShape.disabled = true
	$Attacker.visible = false

func _showAlive():
	rotation.z = 0
	#set_physics_process(true)
	$CollisionShape.disabled = false
	$Attacker.visible = true
