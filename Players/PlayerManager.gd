extends Spatial
class_name PlayerManager

export var player_id: int # The id of the player this manager manages
export var shot_material: Resource
export var laser_material: Resource

signal active_player_died
signal ghost_player_died

var active_player_scene = preload("res://Players/Player.tscn")
var ghost_player_scene = preload("res://Players/Ghost.tscn")

var active_player: Player
var last_ghost: Ghost


func _ready():
	active_player = active_player_scene.instance()
	active_player.id = player_id
	add_child(active_player)
	
	active_player.connect("died", self, "_on_player_died")


func toggle_active_player(active: bool) ->void:
	active_player.visible = active

func set_ghosts_time_scale(time_scale: float) -> void:
	for child in get_children():
		if child != active_player:
			child.set_time_scale(time_scale)


func reset_all_children(frame: int) ->void:
	for child in get_children():
		if child != active_player:
			child.reset(frame)
		else:
			child.reset()


func convert_active_to_ghost(frame: int):
	#if last_ghost:
	#	last_ghost.disconnect("gain_bullet")

	var movement_record = active_player.movement_records
	var new_ghost = ghost_player_scene.instance()
	new_ghost.movement_record = movement_record
	new_ghost.connect("died", self, "_on_ghost_died")
	new_ghost.died_at_frame = frame
	new_ghost.id = active_player.id
	new_ghost.get_node("MeshInstance").material_override.set_shader_param("color", Constants.character_colors[active_player.id + 4])
	new_ghost.set_visibility_mask(active_player.get_used_visibility_mask())
	
	add_child(new_ghost)
	last_ghost = new_ghost
	reset_all_children(frame)


func _on_player_died():
	emit_signal("active_player_died")


func _on_ghost_died():
	emit_signal("ghost_player_died")
