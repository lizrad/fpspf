extends Spatial
class_name PlayerManager


signal active_player_died
signal ghost_player_died

var active_player_scene = preload("res://Players/Player.tscn")
var ghost_player_scene = preload("res://Players/Ghost.tscn")

var active_player: Player


func _ready():
	active_player = active_player_scene.instance()
	add_child(active_player)


func convert_active_to_ghost():
	var movement_record = active_player.movement_records
	
	for child in get_children():
		child.reset()
	
	var new_ghost = ghost_player_scene.instance()
	new_ghost.movement_record = movement_record
	
	add_child(new_ghost)
