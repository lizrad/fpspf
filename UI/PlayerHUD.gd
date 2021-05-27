class_name PlayerHUD
extends Control

onready var _dash_icon_bar := get_node("DashIcon_pb")

func set_dash_progress(value : float) -> void:
	_dash_icon_bar.value = value
