class_name Level
extends Spatial

export (Array, NodePath) var spawn_areas := []


func get_spawn_areas() -> Array:
	return spawn_areas

func get_capture_points() -> Array:
	var capture_point_array := []
	
	for capture_point in $CapturePoints.get_children():
		capture_point_array.append(capture_point)
	
	return capture_point_array

func open_doors() ->void:
	for area in spawn_areas:
		get_node(area).open_doors()

func close_doors() ->void:
	for area in spawn_areas:
		get_node(area).close_doors()
