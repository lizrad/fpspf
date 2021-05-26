extends KinematicBody
class_name Ghost

var movement_record := []

var _frame_timer: float = 0.0
var current_frame : int = 0

var max_health : int = 3
var current_health : int = 3

var died_at_frame : int = INF
var is_dead : bool = false

var _time_scale := 1.0

signal died


func _ready():
	reset()


func set_time_scale(time_scale: float) -> void:
	_time_scale = time_scale

func _physics_process(delta):
	if is_dead:
		return
	
	_frame_timer += delta*_time_scale;
	if abs(_frame_timer)>=delta :
		_frame_timer -= sign(_time_scale)*delta
		current_frame += 1
	
	if current_frame < movement_record.size() and current_frame>=0:
		var frame = movement_record[current_frame]
		global_transform = frame.transform
		if frame.attack_type:
			$Attacker.attack(frame.attack_type, self)
		
		
func receive_damage(damage: float):
	print("Ghost received damage: ", damage)
	current_health -= damage
	
	if current_health <= 0:
		is_dead = true
		died_at_frame = current_frame
		print(" -> Ghost dead")
		emit_signal("died")
		_showDead()


func reset() -> void:
	is_dead = false
	current_frame = 0.0 if _time_scale>=0 else  movement_record.size()-1
	_frame_timer = 0.0
	_set_initial_position()
	current_health = max_health


func _set_initial_position() -> void:
	global_transform = movement_record[0].transform
	
func _showDead():
	rotation.z = PI / 2

func _showAlive():
	rotation.z = 0
