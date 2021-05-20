extends Spatial 
class_name Door

func _ready():
	pass

func open():
	$AnimationPlayer.play("DoorOpening")
	
func close():
	$AnimationPlayer.play_backwards("DoorOpening")

func _process(delta):
	pass
