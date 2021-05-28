class_name Level
extends Spatial

export (Array, NodePath) var spawn_areas := []


func get_spawn_areas() ->Array:
	return spawn_areas

func open_doors() ->void:
	for area in spawn_areas:
		get_node(area).open_doors()

func close_doors() ->void:
	for area in spawn_areas:
		get_node(area).close_doors()
