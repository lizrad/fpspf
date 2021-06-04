extends Spatial

export (NodePath) var current_level

onready var _level : Level = get_node(current_level)

func open_doors():
	_level.open_doors()
	
func close_doors():
	_level.close_doors()

func play_sound_loop() -> void:
	_level.get_node("AudioStreamPlayer").play()

func stop_sound_loop() -> void:
	_level.get_node("AudioStreamPlayer").stop()
