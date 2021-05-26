extends Node

export var time_cycle := 10.0 # total round time in seconds
export var time_prep := 5.0 # time, before the round starts
export var replay_speed := 1.0 # timescale of the replay
export var win_score := 5 # needed score to win game
export var num_cycles := 5 # max cycles for one game

var time_left # round timer in ms
var cycle := 1 # number of current cylce

var _scores := [] # Scores for each player

enum Gamestate {PREP, GAME, REPLAY}
var _current_gamestate = Gamestate.PREP 

func _ready():
	# Connect to player events
	for player_manager in $PlayerManagers.get_children():
		player_manager.connect("active_player_died", self, "_on_active_player_died", [player_manager])
		player_manager.connect("ghost_player_died", self, "_on_ghost_player_died", [player_manager])
		_scores.append(0)
		var attacker = player_manager.active_player.get_node("Attacker")
		attacker.connect("shot_bullet", $HUD, "consume_bullet", [player_manager.player_id])
		time_left = time_prep + 1

	$HUD.set_time(time_left)
	$HUD.set_cycle(cycle)
	$HUD.set_num_cycles(num_cycles)


func _process(delta):
	time_left -= delta
	
	# update ui
	$HUD.set_time(time_left)

	if time_left <= 0:
		next_gamestate()


# used to restart level: 
# 	- reverse shift animation
# 	- storing player movement as ghost
# 	- reset player move list
# 	- reset player starting point
# 	- restarting level time
func next_gamestate():
	print("Switching gamestate from "+Gamestate.keys()[_current_gamestate]+" to "+Gamestate.keys()[(_current_gamestate+1)%Gamestate.size()])
	match _current_gamestate:
		Gamestate.GAME:
			#prepare for replay
			time_left = time_cycle +1
			for player_manager in $PlayerManagers.get_children():
				player_manager.convert_active_to_ghost()
				player_manager.toggle_active_player(false)
			$HUD.set_prep_time(false)
		Gamestate.PREP:
			#prepare for play
			time_left = time_cycle +1
			$HUD.set_prep_time(false)
			$LevelManager.open_doors()
		Gamestate.REPLAY:
			#prepare for prep
			# update cycle -> game over if reached num_cycles
			cycle += 1
			if (cycle > num_cycles):
				print("game over -> cycles")
				get_tree().quit()
				return
			# starting preparation cycle
			$LevelManager.close_doors()
			$HUD.set_cycle(cycle)
			$HUD.reload_ammo()
			for player_manager in $PlayerManagers.get_children():
				var attacker = player_manager.active_player.get_node("Attacker")
				attacker.reload(player_manager.active_player.ranged_attack_type)
				player_manager.toggle_active_player(true)
				player_manager.reset_all_children()
			time_left = time_prep +1
			$HUD.set_prep_time(true)
			
	_current_gamestate = (_current_gamestate+1)%Gamestate.size();
	for id in _scores.size():
		_set_score(id, 0)


func _update_score(id: int) -> void:
	var new_score = _scores[id] + 1
	_set_score(id, new_score)

	# TODO: remove gamemode
	if new_score == win_score:
		print("game over -> score")
		# TODO: end screen to restart game
		return


func _set_score(id: int, score: int) -> void:
	_scores[id] = score
	$HUD.set_score(id, score)


# one of the current active players died:
#	- add score
# 	- restart round
func _on_active_player_died(playerManger: PlayerManager) -> void:
	print("active player died: " + str(playerManger.player_id))
	_update_score(playerManger.player_id)
	
	next_gamestate()


# a ghost clone of one player died:
# 	- add score
func _on_ghost_player_died(playerManger: PlayerManager) -> void:
	print("ghost player died: " + str(playerManger.player_id))
	_update_score(playerManger.player_id)
