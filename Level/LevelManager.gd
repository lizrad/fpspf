extends Spatial

export (NodePath) var current_level

onready var _level : Level = get_node(current_level)

func open_doors():
	_level.open_doors()
	
func close_doors():
	_level.close_doors()
