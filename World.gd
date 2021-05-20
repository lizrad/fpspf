extends Node

export var round_time := 90.0 # total round time in seconds

var left_time # round timer in ms
# TODO: combine into array
var player_manager # holds information about active player and ghosts
var player_manager2

# TODO: combine into scene  with access functions
var label_timer # display for remaining round time
var label_score1 # score for player 1
var label_score2 # score for player 2


func _ready():
	left_time = round_time # round timer in ms
	player_manager = $PlayerManager
	player_manager.connect("active_player_died", self, "_on_active_player_died")
	player_manager.connect("ghost_player_died", self, "_on_ghost_player_died")
	player_manager2 = $PlayerManager2
	player_manager2.connect("active_player_died", self, "_on_active_player_died")
	player_manager2.connect("ghost_player_died", self, "_on_ghost_player_died")
	label_timer = $Timer
	label_score1 = $Score
	label_score2 = $Score2


func _process(delta):
	left_time -= delta
	
	# For UI
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
	print("restarting...")
	left_time = round_time


# one of the current active players died:
#	- add score
# 	- restart round
func _on_active_player_died():
	print("active player died")
	restart()


# a ghost clone of one player died:
# 	- add score
func _on_ghost_player_died():
	print("ghost player died")
