extends Spatial
class_name PlayerManager

export var player_id: int # The id of the player this manager manages
export var player_material: Resource
export var ghost_material: Resource
export var shot_material: Resource

signal active_player_died
signal ghost_player_died

var active_player_scene = preload("res://Players/Player.tscn")
var ghost_player_scene = preload("res://Players/Ghost.tscn")

var active_player: Player


func _ready():
	active_player = active_player_scene.instance()
	active_player.id = player_id
	_set_pawn_material(active_player.get_node("PlayerMesh/CharacterMesh"), player_material)
	
	add_child(active_player)
	
	active_player.connect("died", self, "_on_player_died")


func _set_pawn_material(mesh : MeshInstance, material : Resource) -> void:
	mesh.set_surface_material(0, material)

func toggle_active_player(active: bool) ->void:
	active_player.visible = active

func set_ghosts_time_scale(time_scale: float) -> void:
	for child in get_children():
		if child != active_player:
			child.set_time_scale(time_scale)

func reset_all_children() ->void:
	for child in get_children():
		child.reset()


func convert_active_to_ghost(frame: int):
	var movement_record = active_player.movement_records
	
	reset_all_children()
	
	var new_ghost = ghost_player_scene.instance()
	new_ghost.movement_record = movement_record
	new_ghost.connect("died", self, "_on_ghost_died")
	new_ghost.died_at_frame = frame
	_set_pawn_material(new_ghost.get_node("PlayerMesh/CharacterMesh"), ghost_material)

	add_child(new_ghost)


func _on_player_died():
	emit_signal("active_player_died")


func _on_ghost_died():
	emit_signal("ghost_player_died")
