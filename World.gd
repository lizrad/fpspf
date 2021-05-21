extends Node

export var time_cycle := 10.0 # total round time in seconds
export var time_prep := 5.0 # time, before the round starts
export var win_score := 5 # needed score to win game
export var num_cycles := 5 # max cycles for one game

var time_left # round timer in ms
var cycle := 0 # number of current cylce

var active_prep_time := true # flag to indicate prep or cycle time

var _scores := [] # Scores for each player

var hud # view for current cycle, timer and scores


func _ready():
	# Connect to player events
	for player_manager in $PlayerManagers.get_children():
		player_manager.connect("active_player_died", self, "_on_active_player_died", [player_manager])
		player_manager.connect("ghost_player_died", self, "_on_ghost_player_died", [player_manager])

	time_left = (time_prep if active_prep_time else time_cycle) + 1
	$HUD.set_time(time_left)


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
		$LevelManager.close_doors()
		for player_manager in $PlayerManagers.get_children():
			player_manager.convert_active_to_ghost()
	else:
		cycle += 1
		if (cycle > num_cycles):
			print("game over -> cycles")
			get_tree().quit()
		$HUD.set_cycle(cycle)
		$LevelManager.open_doors()


func _update_score(id: int) -> void:
	_scores[id] += 1
	var score = _scores[id]
	$HUD.set_score(id, score)
	if score == win_score:
		print("game over -> score")
		get_tree().quit()


# one of the current active players died:
#	- add score
# 	- restart round
func _on_active_player_died(playerManger: PlayerManager) -> void:
	print("active player died: " + playerManger.active_player.name)
	_update_score(playerManger.player_id)


# a ghost clone of one player died:
# 	- add score
func _on_ghost_player_died(playerManger: PlayerManager) -> void:
	_update_score(playerManger.player_id)
	print("ghost player died")
