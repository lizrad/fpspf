extends KinematicBody


var movement_record

var current_frame := 0


func _physics_process(delta):
	if current_frame < movement_record.size():
		global_transform = movement_record[current_frame].transform
		current_frame += 1

func Shot(damage) ->void:
	pass
