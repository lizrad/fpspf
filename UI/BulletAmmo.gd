extends Control

# TODO: define in constants for ammotypes
#export var num_bullets : int
#var _num_bullets := num_bullets
var _num_bullets := 9
var _img_bullet = load("res://Attacking/Shots/bullet.png")


func _ready():
	for i in range(_num_bullets):
		var rect = TextureRect.new()
		rect.texture = _img_bullet
		rect.expand = true
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		rect.rect_min_size = Vector2(10, 50)
		$HBoxContainer.add_child(rect)


func add_bullet():
	if _num_bullets >= 9:
		return

	print("regaining bullet[" + str(_num_bullets) + "]")
	$HBoxContainer.get_child(_num_bullets).visible = true
	_num_bullets += 1

func remove_bullet():
	if _num_bullets < 1: 
		return
	
	print("consuming bullet [" + str(_num_bullets - 1) + "]")
	$HBoxContainer.get_child(_num_bullets - 1).visible = false
	_num_bullets -= 1


func reload():
	print("reloading bullets")
	_num_bullets = 9
	for i in range(_num_bullets):
		$HBoxContainer.get_child(i).visible = true
