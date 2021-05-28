class_name PlayerHUD
extends Control

onready var _dash_icon_bar := get_node("TextureRect/DashIcon_pb")
onready var _kill_dashboard := get_node("KillDashboard_pc")
onready var _kill_db_txt := get_node("KillDashboard_pc/KillDashboard_txt")

func set_dash_progress(value : float) -> void:
	_dash_icon_bar.value = value
	if value >= 1.0:
		_dash_icon_bar.tint_progress.a = 1.0
	else:
		_dash_icon_bar.tint_progress.a = 0.5

func add_to_kill_dashboard(text : String) -> void:
	if not _kill_db_txt.text.empty():
		_kill_db_txt.text += "\n"
	_kill_db_txt.text += text
	_kill_dashboard.visible = true

func reset_kill_dashboard() -> void:
	_kill_db_txt.text = ""
	_kill_dashboard.rect_size = Vector2.ZERO
	_kill_dashboard.visible = false
