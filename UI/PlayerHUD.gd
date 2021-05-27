class_name PlayerHUD
extends Control

onready var _dash_icon_bar := get_node("TextureRect/DashIcon_pb")

func set_dash_progress(value : float) -> void:
	_dash_icon_bar.value = value
	if value >= 1.0:
		_dash_icon_bar.tint_progress.a = 1.0
	else:
		_dash_icon_bar.tint_progress.a = 0.5
