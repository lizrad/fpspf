extends Node

export var cycle_time := 90.0 # total round time in seconds
export var win_score := 5

var left_time # round timer in ms
# TODO: combine into array
#var player_manager # holds information about active player and ghosts

var player1 # first player, used to connect score to players

# TODO: combine into UI scene with access functions
var label_timer # display for remaining round time
var label_score1 # score for player 1
var label_score2 # score for player 2


func _ready():
	left_time = cycle_time
	
	for player_manager in $PlayerManagers.get_children():
		if player1 == null:
			player1 = player_manager.active_player
		player_manager.connect("active_player_died", self, "_on_active_player_died", [player_manager.active_player])
		player_manager.connect("ghost_player_died", self, "_on_ghost_player_died", [player_manager.active_player])

	label_timer = $Timer
	label_score1 = $Score
	label_score2 = $Score2


func _process(delta):
	left_time -= delta
	
	# for UI
	var seconds = int(left_time)
	label_timer.set_text("{mm}:{ss}".format({
						 "mm":"%02d" % (seconds / 60),
						 "ss":"%02d" % (seconds % 60)}))
	
	if left_time <= 0:
		restart()


# used to restart level: 
# 	- reverse shift animation
# 	- storing player movement as ghost
# 	- reset player move list
#	- reset player starting point
# 	- restarting level time
func restart():
	left_time = cycle_time
	_updateScore(player1)
	for player_manager in $PlayerManagers.get_children():
		player_manager.convert_active_to_ghost()


func _updateScore(player):
	var label_score = label_score1 if (player == player1) else label_score2
	var val = int(label_score.text) + 1
	label_score.set_text(str(val))
	if val == win_score:
		print("game over")
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
