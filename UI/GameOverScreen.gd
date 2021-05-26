extends Control
class_name GameOverScreen

signal restart_pressed
signal quit_pressed

func _ready():
	hide()
	$Restart_btn.connect("pressed", self, "_on_Restart_btn_pressed")
	$Quit_btn.connect("pressed", self, "_on_Quit_btn_pressed")


func show():
	visible = true

func hide():
	visible = false


func set_winner(idx : int):
	if idx >= 0 && idx <= 1:
		$Winner_txt.text = "Player " + str(idx + 1) + " won!"
		$Winner_txt.add_color_override("font_color", Constants.character_colors[idx])
		$Winner_txt.add_color_override("font_outline_modulate", Constants.character_colors[idx])
	else:
		$Winner_txt.text = "Draw!"


func _on_Restart_btn_pressed():
	get_tree().reload_current_scene()
	emit_signal("restart_pressed")

func _on_Quit_btn_pressed():
	get_tree().quit()
	emit_signal("quit_pressed")
