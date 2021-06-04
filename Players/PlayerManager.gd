extends Spatial
class_name PlayerManager

export var player_id: int # The id of the player this manager manages

signal active_player_died
signal ghost_player_died

var active_player_scene = preload("res://Players/Player.tscn")
var ghost_player_scene = preload("res://Players/Ghost.tscn")

var active_player: Player
var last_ghost: Ghost

# TODO: use array for ghosts instead of get_children


func _ready():
	active_player = active_player_scene.instance()
	active_player.id = player_id
	add_child(active_player)
	
	active_player.connect("died", self, "_on_player_died")
	active_player.connect("switched_pawn", self, "_on_pawn_switched")


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
	var movement_record = active_player.movement_records
	var new_ghost = ghost_player_scene.instance()
	add_child(new_ghost)
	
	new_ghost.movement_record = movement_record
	new_ghost.died_at_frame = frame
	new_ghost.id = active_player.id
	new_ghost.get_node("MeshInstance").material_override.set_shader_param("color", Constants.character_colors[active_player.id + 4])
	new_ghost.set_visibility_mask(active_player.get_used_visibility_mask())
	new_ghost.set_correct_colors(new_ghost.id + 4) # light version of player
	new_ghost.connect("died", self, "_on_ghost_died", [new_ghost.get_index()])
	last_ghost = new_ghost
	reset_all_children(frame)


# denies killing in spawning area,
# also reset colors
func set_pawns_invincible(invincible : bool):
	for child in get_children():
		child.invincible = invincible

		# reset selection to base colors
		if invincible == false:
			if child != active_player:
				child.set_correct_colors(player_id + 4)  # ghost
			else:
				child.set_correct_colors(player_id)  # active player


func _on_player_died():
	emit_signal("active_player_died")
	active_player.add_to_kill_dashboard("Player died")

func _on_ghost_died(ghost_index : int):
	emit_signal("ghost_player_died")
	active_player.add_to_kill_dashboard("Ghost " + str(ghost_index) + " died")


func _on_pawn_switched(idx : int) -> void:
	var allowed = get_children().size()
	#print(name, " switched pawn: ", idx, " of ", allowed)
	idx = idx % allowed
	if idx < allowed:
		for cand in allowed:
			var pawn = get_child(cand)
			if cand == idx:
				pawn.set_correct_colors(8) # currently selected
			elif cand == 0: # active player
				pawn.set_correct_colors(player_id)  # active player
			else:
				pawn.set_correct_colors(player_id + 4)  # ghost
	active_player.selected_pawn = idx
