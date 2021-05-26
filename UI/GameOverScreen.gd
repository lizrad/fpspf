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

func set_winner_text(text : String):
	$Winner_txt.text = text


func set_winner_text_color(color : Color):
	$Winner_txt.add_color_override("font_color", color)

func _on_Restart_btn_pressed():
	emit_signal("restart_pressed")

func _on_Quit_btn_pressed():
	emit_signal("quit_pressed")
