extends Spatial


signal active_player_died
signal ghost_player_died

var active_player_scene = preload("res://Players/Player.tscn")
var ghost_player_scene = preload("res://Players/Ghost.tscn")

var active_player


func _ready():
	active_player = active_player_scene.instance()
	add_child(active_player)
