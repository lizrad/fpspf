class_name Level
extends Spatial

export (Array, NodePath) var spawn_areas := []
export (Array, NodePath) var capture_points := []


func get_spawn_areas() -> Array:
	return spawn_areas

func get_capture_points() -> Array:
	var capture_point_array := []
	for capture_point in capture_points:
		capture_point_array.append(get_node(capture_point)) 
	return capture_point_array

func open_doors() ->void:
	for area in spawn_areas:
		get_node(area).open_doors()

func close_doors() ->void:
	for area in spawn_areas:
		get_node(area).close_doors()
