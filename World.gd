extends Node

export var round_time := 90 # total round time in seconds

var left_time # round timer in ms
var label_timer # display for remaining round time
var player_manager # holds information about players

# Called when the node enters the scene tree for the first time.
func _ready():
	left_time = round_time*1000 # round timer in ms
	label_timer = get_node("Timer")
	player_manager = get_node("PlayerManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	left_time -= delta*1000
	var seconds = int(left_time/1000)
	# TODO: string format 00:00
	label_timer.set_text(String(seconds/60) + ":" + String(seconds%60))
	if (left_time <= 0):
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
	left_time = round_time*1000
