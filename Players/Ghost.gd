extends Spatial


var movement_record

var current_frame := 0


func _ready():
	reset()


func _physics_process(delta):
	if current_frame < movement_record.size():
		global_transform = movement_record[current_frame].transform
		current_frame += 1


func reset() -> void:
	current_frame = 0
	_set_initial_position()


func _set_initial_position() -> void:
	global_transform = movement_record[0].transform
