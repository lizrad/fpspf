extends KinematicBody
class_name Ghost

var movement_record

var current_frame := 0

var max_health := 3
var current_health := 3

signal died


func _ready():
	reset()


func _physics_process(delta):
	if current_frame < movement_record.size():
		var frame = movement_record[current_frame]
		
		global_transform = frame.transform
		if frame.attack_type:
			$Attacker.attack(frame.attack_type, self)

		current_frame += 1


func receive_damage(damage: float):
	print("Ghost received damage: ", damage)
	current_health -= damage
	
	if current_health <= 0:
		print("	-> Ghost dead")
		emit_signal("died")
		queue_free()


func reset() -> void:
	current_frame = 0
	_set_initial_position()
	current_health = max_health


func _set_initial_position() -> void:
	global_transform = movement_record[0].transform
