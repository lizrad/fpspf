extends KinematicBody


var movement_record

var current_frame := 0

signal died


func _ready():
	reset()


func _physics_process(delta):
	if current_frame < movement_record.size():
		var frame = movement_record[current_frame]
		
		global_transform = frame.transform
		if frame.is_shooting:
			$Shooter.Shoot()
		
		current_frame += 1


func receive_damage(damage) ->void:
	# TODO: Check against health
	emit_signal("died")


func reset() -> void:
	current_frame = 0
	_set_initial_position()


func _set_initial_position() -> void:
	global_transform = movement_record[0].transform
