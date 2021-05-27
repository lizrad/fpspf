extends CharacterBase
class_name Ghost

var movement_record := []

var _frame_timer: float = 0.0
var current_frame : int = 0

var _current_health : int = 3

var died_at_frame : int = INF

var _time_scale := 1.0

var _dead = false
var _first_alive_frame = true
var _previous_attack_frame = -1

signal died


func set_time_scale(time_scale: float) -> void:
	_time_scale = time_scale

func _physics_process(delta):
	_frame_timer += delta*abs(_time_scale);
	while _frame_timer>=delta :
		_frame_timer -= delta
		current_frame += (sign(_time_scale)*1)
	
	if _time_scale>=0:
		if current_frame < movement_record.size() and not _dead:
			var frame = movement_record[current_frame]
			global_transform = frame.transform
			if frame.attack_type:
				$Attacker.attack(frame.attack_type, self)
	else :
		if current_frame>=0:
			if current_frame < died_at_frame and current_frame<movement_record.size():
				if _first_alive_frame:
					_first_alive_frame=false
					_showAlive()
				
				#looking into the future (== past in this case) to find out if we will attack, so we can spawn the visualization preemptively
				var attack_future_frame_index = int(current_frame - ($Attacker.visualization_time/ get_physics_process_delta_time()))
				
				if attack_future_frame_index!=_previous_attack_frame:
					_previous_attack_frame = attack_future_frame_index
					var attack_frame = movement_record[attack_future_frame_index] if attack_future_frame_index>=0 else null
					if attack_frame:
						if attack_frame.attack_type:
							global_transform = attack_frame.transform
							$Attacker.visualize_attack(attack_frame.attack_type, self)
				
				var frame = movement_record[current_frame]
				global_transform = frame.transform
				

func receive_damage(damage: float):
	print("Ghost received damage: ", damage)
	_current_health -= damage
	
	if _current_health <= 0:
		died_at_frame = current_frame
		print(" -> Ghost dead")
		emit_signal("died")
		_showDead()


func reset(start_frame : int) -> void:
	current_frame = start_frame
	_frame_timer = 0.0
	if start_frame!=0 :
		_showDead()
		_first_alive_frame=true
		_previous_attack_frame=-1
	else:
		_showAlive()

	_set_initial_position()
	_current_health = Constants.max_health


func _set_initial_position() -> void:
	var start_frame = current_frame if current_frame < movement_record.size() else movement_record.size()-1
	global_transform = movement_record[start_frame].transform


func _showDead():
	_dead = true
	rotation.z = PI / 2
	$CollisionShape.disabled = true
	$Attacker.visible = false


func _showAlive():
	_dead = false
	rotation.z = 0
	$CollisionShape.disabled = false
	$Attacker.visible = true
