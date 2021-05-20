extends Node

export var round_time := 90.0 # total round time in seconds

var left_time # round timer in ms
var label_timer # display for remaining round time
var player_manager # holds information about players


func _ready():
	left_time = round_time # round timer in ms
	label_timer = $Timer
	player_manager = $PlayerManager


func _process(delta):
	left_time -= delta
	
	# For UI
	var seconds = int(left_time)
	# TODO: string format 00:00
	label_timer.set_text(String(seconds / 60) + ":" + String(seconds % 60))
	
	if left_time <= 0:
		restart()
	
	# TODO: check player health and end round or handle per signals
	#player_manager.activePlayer...


# used to restart level: 
# 	- reverse shift animation
# 	- storing player movement as ghost
# 	- reset player move list
#	- reset player starting point
# 	- restarting level time
func restart():
	print("restarting...")
	left_time = round_time
