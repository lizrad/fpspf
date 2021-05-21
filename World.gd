extends Node

export var time_cycle := 10.0 # total round time in seconds
export var time_prep := 5.0 # time, before the round starts
export var win_score := 5 # needed score to win game
export var num_cycles := 5 # max cycles for one game

var time_left # round timer in ms
var cycle := 1 # number of current cylce

var active_prep_time := true # flag to indicate prep or cycle time

var _scores := [] # Scores for each player


func _ready():
	# Connect to player events
	for player_manager in $PlayerManagers.get_children():
		player_manager.connect("active_player_died", self, "_on_active_player_died", [player_manager])
		player_manager.connect("ghost_player_died", self, "_on_ghost_player_died", [player_manager])
		_scores.append(0)
		var attacker = player_manager.active_player.get_node("Attacker")
		attacker.connect("shot_bullet", $HUD, "_consume_bullet", [player_manager.player_id])

	time_left = (time_prep if active_prep_time else time_cycle) + 1
	$HUD.set_time(time_left)
	$HUD.set_cycle(cycle)
	$HUD.set_num_cycles(num_cycles)


func _process(delta):
	time_left -= delta
	
	# update ui
	$HUD.set_time(time_left)

	if time_left <= 0:
		restart()


# used to restart level: 
# 	- reverse shift animation
# 	- storing player movement as ghost
# 	- reset player move list
#	- reset player starting point
# 	- restarting level time
func restart():
	active_prep_time = !active_prep_time
	$HUD.set_prep_time(active_prep_time)
	print("start " + ("preparation" if active_prep_time else "cycle"))
	time_left = (time_prep if active_prep_time else time_cycle) + 1
	if active_prep_time:
		# update cycle -> game over if reached num_cycles
		cycle += 1
		if (cycle > num_cycles):
			print("game over -> cycles")
			get_tree().quit()
		$HUD.set_cycle(cycle)
		
		# starting preparation cycle
		$LevelManager.close_doors()
		for player_manager in $PlayerManagers.get_children():
			player_manager.convert_active_to_ghost()
			var attacker = player_manager.active_player.get_node("Attacker")
			attacker.reload(player_manager.active_player.ranged_attack_type)
	else:
		$LevelManager.open_doors()
	
	for id in _scores.size():
		_set_score(id, 0)


func _update_score(id: int) -> void:
	var new_score = _scores[id] + 1
	_set_score(id, new_score)
	
	if _scores[id] == win_score:
		print("game over -> score")
		get_tree().quit


func _set_score(id: int, score: int) -> void:
	_scores[id] = score
	$HUD.set_score(id, score)


# one of the current active players died:
#	- add score
# 	- restart round
func _on_active_player_died(playerManger: PlayerManager) -> void:
	print("active player died: " + playerManger.active_player.name)
	_update_score(playerManger.player_id)
	
	restart()


# a ghost clone of one player died:
# 	- add score
func _on_ghost_player_died(playerManger: PlayerManager) -> void:
	_update_score(playerManger.player_id)
	print("ghost player died")
