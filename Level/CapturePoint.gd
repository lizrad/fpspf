class_name CapturePoint
extends Spatial

signal capture_team_changed(team_id)
signal captured(team_id)
signal capture_lost(team_id)

export var instant_capture : bool = true


var _capture_progress : float = 0
# Team that currently 'owns' the capturing point
var _capture_team : int = -1
# Team that currently takes over the capturing point
var _current_capture_team : int = -1

var _being_captured : bool = false
var _capturing_paused : bool = false
var _is_captured : bool = false
var _active : bool = true
var _capturing_entities := [0,0]

onready var _mesh = get_node("MeshInstance")

func _ready():
	_mesh.material_override = SpatialMaterial.new()
	_mesh.material_override.albedo_color = Color.gray
	
	$Area.connect("body_entered", self, "_on_body_entered_area")
	$Area.connect("body_exited", self, "_on_body_exited_area")

func _process(delta):
	if _capturing_paused or instant_capture:
		return
	
	if _being_captured:
		if _current_capture_team == _capture_team:
			# Current team increases the capture process
			_capture(delta / Constants.capture_time)
		else:
			# Enemy team decreases capture process and takes over point
			_recapture(delta / Constants.capture_time)
	else:
		# No team is capturing -> progress decreases
		_release(delta / Constants.capture_time)


func get_capture_progress() -> float:
	return _capture_progress

func get_capture_team() -> int:
	return _capture_team

func start_capturing(team_id : int):
	_capturing_entities[team_id] += 1
	_check_capturing_status()

func stop_capturing(team_id : int):
	_capturing_entities[team_id] -= 1
	_check_capturing_status()

func reset_point() -> void:
	_capturing_entities[0] = 0
	_capturing_entities[1] = 0
	_capture_team = -1
	_capture_progress = 0
	_check_capturing_status()
	_set_capture_color(false)

func _capture(delta : float):
	_capture_progress = min(1, _capture_progress + delta * Constants.capture_speed)
	if _capture_progress == 1 and not _is_captured:
		_is_captured = true
		emit_signal("captured", _capture_team)
		_set_capture_color(true)

func _recapture(delta : float):
	if _capture_progress > 0:
		_capture_progress = max(0, _capture_progress - delta * Constants.recapture_speed)
	else:
		_switch_capturing_teams(_current_capture_team)


func _release(delta : float):
	if _capture_progress > 0:
		if _capture_progress == 1:
			_is_captured = false
			emit_signal("capture_lost", _capture_team)
		_capture_progress = max(0, _capture_progress - delta * Constants.capture_release_speed)
	elif _capture_team != -1:
		# Process reached zero with no team currently capturing
		_reset_capture_point()


func _reset_capture_point():
	_capturing_entities[0] = 0
	_capturing_entities[1] = 0
	_capture_team = -1
	_capture_progress = 0
	_check_capturing_status()
	_set_capture_color(false)
	emit_signal("capture_team_changed", -1)

func _switch_capturing_teams(new_team : int):
	_capture_team = new_team
	emit_signal("capture_team_changed", new_team)

func _check_capturing_status():
	_capturing_paused = _capturing_entities[0] > 0 and _capturing_entities[1] > 0
	_being_captured = _capturing_entities[0] > 0 or _capturing_entities[1] > 0
	_current_capture_team = 0 if _capturing_entities[0] > _capturing_entities[1] else 1


func _set_capture_color(is_captured : bool):
	_mesh.material_override.albedo_color = \
		Constants.character_colors[_capture_team] if is_captured \
		else Constants.capture_point_color_neutral

func toggle_active(toggle:bool)->void:
	_active = toggle
	
func _on_body_entered_area(body):
	if not _active:
		return
	if body is CharacterBase:
		if instant_capture:
			if _capture_team != body.id:
				if _capture_team != -1:
					emit_signal("capture_lost", _capture_team)
				_capture_team = body.id
				_current_capture_team = body.id
				emit_signal("captured", _capture_team)
				_set_capture_color(true)
		else:
			start_capturing(body.id)

func _on_body_exited_area(body):
	if not _active:
		return
	if body is CharacterBase:
		if not instant_capture:
			stop_capturing(body.id)
