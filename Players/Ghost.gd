extends CharacterBase
class_name Ghost

var movement_record := []

var _frame_timer: float = 0.0
var current_frame : int = 0

var died_at_frame : int = INF

var _time_scale := 1.0

var _dead = false
var _first_alive_frame = true
var _ranged_previous_ranged_attack_frame = -1
var _melee_previous_melee_attack_frame = -1

signal died


func set_time_scale(time_scale: float) -> void:
	_time_scale = time_scale

func _physics_process(delta):
	_frame_timer += delta*abs(_time_scale);
	while _frame_timer>=delta :
		_frame_timer -= delta
		current_frame += (sign(_time_scale)*1)
		if _time_scale>=0:
			# normal playback
			if current_frame < movement_record.size() and not _dead:
				var frame = movement_record[current_frame]
				global_transform = frame.transform
				if frame.attack_type:
					$Attacker.attack(frame.attack_type, self)
		else :
			# replay
			if current_frame>=0:
				if current_frame < died_at_frame and current_frame < movement_record.size():
					if _first_alive_frame:
						_first_alive_frame=false
						_show_alive()
					
					
					#looking into the future (== past in this case) to find out if we will attack, so we can spawn the visualization preemptively
					# TODO: this is a acky fix - doing this seperatelly for both attack types
					var ranged_attack_future_frame_index = int(current_frame - (Constants.ranged_attack_type.attack_time/ get_physics_process_delta_time()))
					if ranged_attack_future_frame_index!=_ranged_previous_ranged_attack_frame:
						_ranged_previous_ranged_attack_frame = ranged_attack_future_frame_index
						var ranged_attack_frame = movement_record[ranged_attack_future_frame_index] if ranged_attack_future_frame_index>=0 else null
						if ranged_attack_frame:
							if ranged_attack_frame.attack_type == Constants.ranged_attack_type:
								global_transform = ranged_attack_frame.transform
								$Attacker.visualize_attack(ranged_attack_frame.attack_type, self)
								
					var melee_attack_future_frame_index = int(current_frame - (Constants.melee_attack_type.attack_time/ get_physics_process_delta_time()))
					if melee_attack_future_frame_index!=_melee_previous_melee_attack_frame:
						_melee_previous_melee_attack_frame = melee_attack_future_frame_index
						var melee_attack_frame = movement_record[melee_attack_future_frame_index] if melee_attack_future_frame_index>=0 else null
						if melee_attack_frame:
							if melee_attack_frame.attack_type == Constants.melee_attack_type:
								global_transform = melee_attack_frame.transform
								$Attacker.visualize_attack(melee_attack_frame.attack_type, self)
					
					var frame = movement_record[current_frame]
					global_transform = frame.transform
				else:
					var frame = movement_record[died_at_frame if died_at_frame < movement_record.size() else movement_record.size() - 1]
					global_transform = frame.transform

func receive_damage(damage: float):
	print("Ghost received damage: ", damage)
	if invincible:
		print("	but is invincible!")
		return
	if _dead:
		return
	set_current_health(_current_health - damage)
	
	if _current_health <= 0:
		died_at_frame = current_frame
		print(" -> Ghost dead")
		emit_signal("died")
		_show_dead()


func reset(start_frame : int) -> void:
	current_frame = start_frame
	_frame_timer = -get_physics_process_delta_time()
	if start_frame!=0 :
		_show_dead()
		_first_alive_frame=true
		_ranged_previous_ranged_attack_frame=-1
	else:
		_show_alive()
	_set_initial_position()
	set_current_health(Constants.max_health)


func _set_initial_position() -> void:
	var start_frame = current_frame if current_frame < movement_record.size() else movement_record.size()-1
	global_transform = movement_record[start_frame].transform


func _show_dead():
	_dead = true
	rotation.z = PI / 2
	$CollisionShape.disabled = true
	$Attacker.visible = false
	$VisibilityLights.set_enabled(false)


func _show_alive():
	_dead = false
	rotation.z = 0
	$CollisionShape.disabled = false
	$Attacker.visible = true
	$VisibilityLights.set_enabled(true)
