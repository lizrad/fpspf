extends CharacterBase
class_name Ghost

var movement_record := []

var _frame_timer: float = 0.0
var current_frame : int = 0

var died_at_frame : int = INF

var played_in_round: int

var _time_scale := 1.0

var _first_alive_frame = true
var _ranged_previous_ranged_attack_frame = -1
var _previous_future_attack_frame_index = -1
var _melee_previous_melee_attack_frame = -1

signal died

	
func set_time_scale(time_scale: float) -> void:
	_time_scale = time_scale

func _physics_process(delta):
	_frame_timer += delta*abs(_time_scale);
	#simulate multiple frames in on physics frame if _time_scale is sped up, so we don't skip possible attack_frames
	while _frame_timer>=delta :
		_frame_timer -= delta
		current_frame += (sign(_time_scale))
		
		#skip frame if it is in any way invalid
		if not _is_valid_frame(current_frame):
			continue
		
		# if if we turn back time the ghost starts dead, so we have to revive it at some point
		if _time_scale<0 && current_frame < died_at_frame:
			if _dead:
				_show_alive()
		
		var frame = _get_frame(current_frame)
		_apply_frame_transform(frame)
		var attack_frame = _get_attack_frame(frame)
		_perform_attack(attack_frame)

func _is_valid_frame(frame) ->bool:
	# time_scale 0 should not change anything, therefor physics frame should not run
	if _time_scale == 0:
		return false
	# frames only start at 0
	if frame<0:
		return false
	# frames index movement records => have to be smaller than size
	if frame>= movement_record.size():
		return	false
	# if we use forward time and we are dead, nothing should happen anymore
	if _time_scale>=0 && _dead:
		return false
	return true

func _perform_attack(attack_frame):
	# if no attack was performed skip
	if not attack_frame.attack_type:
		return
	# store current transform so we can reset it afterwards
	var prev_transform = global_transform
	# put ghost into right spot
	global_transform = attack_frame.transform
	# and depending on forward or backward time perform the attack or visualize it
	if _time_scale >0:
		$Attacker.attack(attack_frame.attack_type, self)
	else: 
		$Attacker.visualize_attack(attack_frame.attack_type, self)
	#reset position
	global_transform = prev_transform

func _get_frame(current_frame):
	var frame = current_frame
	# if we have backwards time, the ghost has to stay at the spot he died at until we move past that point in time
	if _time_scale < 0 && frame > died_at_frame:
			frame = died_at_frame
	frame = clamp(frame,0,(movement_record.size() - 1))
	return frame

func _get_attack_frame(frame):
	# in forward time attack_frame is equal to normal time
	var attack_frame = movement_record[frame]
	# in backward time we have to look a bit into the past
	if _time_scale<0:
		# first look back for the ranged attack
		var future_attack_frame_index = int(frame - (Constants.ranged_attack_type.attack_time/ get_physics_process_delta_time()))
		if future_attack_frame_index!=_previous_future_attack_frame_index:
				future_attack_frame_index = clamp(future_attack_frame_index,0,movement_record.size()-1);
				attack_frame = movement_record[future_attack_frame_index]
		# if we did not find one look back for melee attack
		if not attack_frame.attack_type:
			future_attack_frame_index = int(frame - (Constants.melee_attack_type.attack_time/ get_physics_process_delta_time()))
			if future_attack_frame_index!=_previous_future_attack_frame_index:
				future_attack_frame_index = clamp(future_attack_frame_index,0,movement_record.size()-1);
				attack_frame = movement_record[future_attack_frame_index]
		_previous_future_attack_frame_index = future_attack_frame_index
	return attack_frame

func _apply_frame_transform(frame):
	var record = movement_record[frame]
	global_transform = record.transform

func receive_hit(attack_type_typ, damage: float, bounce: Vector3):
	if invincible:
		return
	if _dead:
		return
	
	$HitParticles.emitting=true
	set_current_health(_current_health - damage)
	if _current_health <= 0:
		died_at_frame = current_frame
		_show_dead()
		emit_signal("died")


func reset(start_frame : int) -> void:
	current_frame = start_frame
	_frame_timer = -get_physics_process_delta_time()
	if start_frame!=0 :
		_show_dead()
		_first_alive_frame=true
		_ranged_previous_ranged_attack_frame = -1
		_melee_previous_melee_attack_frame = -1
	else:
		_show_alive()
	_set_initial_position()
	set_current_health(Constants.max_health)


func _set_initial_position() -> void:
	var start_frame = current_frame if current_frame < movement_record.size() else movement_record.size()-1
	global_transform = movement_record[start_frame].transform


func die():
	_show_dead()

func _show_dead():
	._show_dead()
	$VisibilityLights.set_enabled(false)


func _show_alive():
	_dead = false
	rotation.z = 0
	$CollisionShape.disabled = false
	$Attacker.visible = true
	$VisibilityLights.set_enabled(true)
