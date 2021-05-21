extends Control

var _num_bullets := 5
var _img_bullet = load("res://Attacking/Shots/bullet.png")


func _ready():
	for i in range(_num_bullets):
		var rect = TextureRect.new()
		rect.texture = _img_bullet
		rect.expand = true
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		rect.rect_min_size = Vector2(10, 50)
		$HBoxContainer.add_child(rect)


func remove_bullet():
	if _num_bullets < 1: 
		return
	
	print("shooting bullet " + str(_num_bullets - 1))
	$HBoxContainer.get_child(_num_bullets - 1).visible = false
	_num_bullets -= 1


func reload(player):
	print("reloading bullets")
	for i in range(_num_bullets):
		$HBoxContainer.get_child(_num_bullets - 1).visible = true
	_num_bullets = 5