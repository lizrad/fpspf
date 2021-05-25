extends Spatial
class_name PlayerManager

export var player_id: int # The id of the player this manager manages
export var player_material: Resource
export var ghost_material: Resource
export var shot_material: Resource # or color? TODO: where is this used?

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


func convert_active_to_ghost():
	var movement_record = active_player.movement_records
	
	for child in get_children():
		child.reset()
	
	var new_ghost = ghost_player_scene.instance()
	new_ghost.movement_record = movement_record
	new_ghost.connect("died", self, "_on_ghost_died")
	_set_pawn_material(new_ghost.get_node("PlayerMesh/CharacterMesh"), ghost_material)

	add_child(new_ghost)


func _on_player_died():
	emit_signal("active_player_died")


func _on_ghost_died():
	emit_signal("ghost_player_died")
