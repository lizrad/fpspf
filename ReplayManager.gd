class_name ReplayManager
extends Node

var _old_camera : Camera

onready var _view_port_container := get_node("ViewportContainer")

func _ready():
	_view_port_container.visible = false

func show_replay_camera():
	_view_port_container.visible = true
	
func hide_replay_camera():
	_view_port_container.visible = false
