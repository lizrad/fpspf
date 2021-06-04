extends Control
class_name GameOverScreen

signal restart_pressed
signal quit_pressed

onready var _winner_txt := get_node("PanelContainer/VBoxContainer/Winner_txt")
onready var _restart_btn := get_node("PanelContainer/VBoxContainer/HBoxContainer/Restart_btn")
onready var _quit_btn := get_node("PanelContainer/VBoxContainer/HBoxContainer/Quit_btn")

func _ready():
	hide()
	_restart_btn.connect("pressed", self, "_on_Restart_btn_pressed")
	_quit_btn.connect("pressed", self, "_on_Quit_btn_pressed")


func show():
	visible = true
	$GameOverSound.play()

func hide():
	visible = false


func set_winner(idx : int):
	if idx >= 0 && idx <= 1:
		_winner_txt.text = "Player " + str(idx + 1) + " won!"
		_winner_txt.add_color_override("font_color", Constants.character_colors[idx])
		_winner_txt.add_color_override("font_outline_modulate", Constants.character_colors[idx])
	else:
		_winner_txt.text = "Draw!"
		_winner_txt.add_color_override("font_color", Color.white)


func _on_Restart_btn_pressed():
	get_tree().reload_current_scene()
	emit_signal("restart_pressed")

func _on_Quit_btn_pressed():
	get_tree().quit()
	emit_signal("quit_pressed")
