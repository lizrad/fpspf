extends Node

export var time_cycle := 10.0 # total round time in seconds
export var time_prep := 5.0 # time, before the round starts
export var win_score := 5 # needed score to win game
export var num_cycles := 5 # max cycles for one game

var time_left # round timer in ms
var cycle := 0 # number of current cylce
# TODO: combine into array
#var player_manager # holds information about active player and ghosts

var active_prep_time := true # flag to indicate prep or cycle time

var player1 # first player, used to connect score to players
var _score1 := 0 # score for player one
var _score2 := 0 # score for player two

var hud # view for current cycle, timer and scores


func _ready():
	for player_manager in $PlayerManagers.get_children():
		if player1 == null:
			player1 = player_manager.active_player
		player_manager.connect("active_player_died", self, "_on_active_player_died", [player_manager.active_player])
		player_manager.connect("ghost_player_died", self, "_on_ghost_player_died", [player_manager.active_player])

	time_left = (time_prep if active_prep_time else time_cycle) + 1
	$HUD.set_time(time_left)
	#restart()


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
		# TODO: remove, test only
		_updateScore(player1)
	
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


func _updateScore(player):
	var score = _score1 if player == player1 else _score2
	score += 1
	$HUD.set_score(0 if player == player1 else 1, score)
	if score == win_score:
		print("game over -> score")
		get_tree().quit()


# one of the current active players died:
#	- add score
# 	- restart round
func _on_active_player_died(player):
	print("active player died: " + player.name)
	_updateScore(player)
	restart()


# a ghost clone of one player died:
# 	- add score
func _on_ghost_player_died(player):
	_updateScore(player)
	print("ghost player died")
