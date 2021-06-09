extends Node

export var time_cycle := 10.0 # total round time in seconds
export var time_prep := 5.0 # time, before the round starts
export var replay_speed := 1.0 # timescale of the replay
export var num_cycles := 5 # max cycles for one game
export var music_enabled := true

export var use_total_kills : bool = false
export var use_continuous_mode : bool = false


var time_left # round timer in ms
var cycle := 1 # number of current cylce

onready var _replay_manager := get_node("ReplayManager")
onready var _player_managers := []

var _scores := [] # Scores for each player
var _current_gamestate = Constants.Gamestate.PREP 
var _current_frame := 0

# the maximum number of frames a cycle took
var _max_frames : int = 0
var _an_active_player_died : bool = false


func _ready():
	# connect to player events
	for player_manager in $PlayerManagers.get_children():
		_player_managers.append(player_manager)
		player_manager.connect("active_player_died", self, "_on_active_player_died", [player_manager])
		player_manager.connect("ghost_player_died", self, "_on_ghost_player_died", [player_manager])
		_scores.append(0)
		var attacker = player_manager.active_player.get_node("Attacker")
		attacker.connect("shot_bullet", $HUD, "consume_bullet", [player_manager.player_id])
		time_left = time_prep + 1
		$HUD.set_player_attack_type(player_manager.player_id, player_manager.active_player.ranged_attack_type)

	$HUD.set_time(time_left)
	$HUD.set_cycle(cycle)
	$HUD.set_num_cycles(num_cycles)


func _process(delta):
	time_left -= (delta *(1 if _current_gamestate != Constants.Gamestate.REPLAY else replay_speed))
	
	# update ui
	$HUD.set_time(time_left)
	if time_left <= 0:
		next_gamestate()

func _physics_process(delta):
	if _current_gamestate != Constants.Gamestate.REPLAY:
		_current_frame += 1
	
	# if an active player died and all ghosts are finished playing, go to next gamestate
	if use_continuous_mode:
		if _an_active_player_died and _current_frame >= _max_frames:
			next_gamestate()


# used to restart level: 
# 	- reverse shift animation
# 	- storing player movement as ghost
# 	- reset player move list
# 	- reset player starting point
# 	- restarting level time
func next_gamestate():
	print("Switching gamestate from "+Constants.Gamestate.keys()[_current_gamestate]+" to "+Constants.Gamestate.keys()[(_current_gamestate+1)%Constants.Gamestate.size()])
	match _current_gamestate:
		Constants.Gamestate.GAME:
			# prepare for replay
			if music_enabled:
				$LevelManager.stop_sound_loop() # TODO: play loop in reverse?
			_replay_manager.show_replay_camera()
			for player_manager in $PlayerManagers.get_children():
				player_manager.active_player.get_node("Attacker").reset()
				player_manager.convert_active_to_ghost(_current_frame - 1)
				# get last created ghost and connect to bullet gain
				var attacker = player_manager.last_ghost.get_node("Attacker")
				attacker.connect("gain_bullet", $HUD, "regain_bullet", [player_manager.player_id])

				player_manager.set_pawns_invincible(true)
				player_manager.set_ghosts_time_scale(-replay_speed)
				player_manager.toggle_active_player(false)
			time_left = _current_frame*get_physics_process_delta_time()
			_current_frame = 0

		Constants.Gamestate.PREP:
			# prepare for play
			time_left = time_cycle + 1
			$LevelManager.open_doors()
			if music_enabled:
				$LevelManager.play_sound_loop()
			for player_manager in $PlayerManagers.get_children():
				player_manager.set_pawns_invincible(false)
				player_manager.replace_ghost()

		Constants.Gamestate.REPLAY:
			# prepare for prep
			_an_active_player_died = false
			_replay_manager.hide_replay_camera()
			# update cycle -> game over if reached num_cycles
			cycle += 1
			if (cycle > num_cycles):
				$HUD.set_winner(_get_winner())
				$HUD.toggle_game_over_screen(true)
				set_process(false)
				return

			# starting preparation cycle
			$LevelManager.close_doors()
			$HUD.set_cycle(cycle)
			$HUD.reload_ammo()
			for player_manager in $PlayerManagers.get_children():
				player_manager.last_ghost.get_node("Attacker").reset()
				var attacker = player_manager.active_player.get_node("Attacker")
				attacker.reload_all()
				# disconnect ghosts from bullet refill
				attacker.disconnect("gain_bullet", $HUD, "regain_bullet")

				player_manager.set_ghosts_time_scale(1.0)
				player_manager.reset_all_children(0)
				player_manager.toggle_active_player(true)
			time_left = time_prep + 1
			# reset scores
			if not use_total_kills:
				for id in _scores.size():
					_set_score(id, 0)

	_current_gamestate = (_current_gamestate + 1) % Constants.Gamestate.size();
	$HUD.set_game_state(_current_gamestate)


func _get_winner() -> int:
	var max_score := 0
	var winner := 0
	var idx := 0
	for score in _scores:
		if score > max_score:
			max_score = score
			winner = idx
		elif score == max_score:
			winner = -1
		idx += 1
	return winner


func _set_score(id: int, score: int) -> void:
	_scores[id] = score
	$HUD.set_score(id, score)

func _score_point(id: int):
	_set_score(id, _scores[id] + 1)


# FIXME: this only works for 2 players because the player who shots is never transmitted
func _get_opponent_player(id: int) -> int:
	for player_manager in $PlayerManagers.get_children():
		if player_manager.player_id != id:
			return player_manager.player_id
	return -1

# one of the current active players died:
#	- add score
# 	- restart round if cycle 1
func _on_active_player_died(playerManger: PlayerManager) -> void:
	_score_point(_get_opponent_player(playerManger.player_id))
	
	_an_active_player_died = true
	_replay_manager.show_replay_camera()
		
	for player_manager in _player_managers:
		player_manager.active_player.input_enabled = false
	
	if _max_frames < _current_frame:
		_max_frames = _current_frame
	
	# Always stop on cycle 1 if active player dies	
	if not use_continuous_mode:
		next_gamestate()
	elif cycle == 1:
		next_gamestate()


# a ghost clone of one player died:
# 	- add score
func _on_ghost_player_died(playerManger: PlayerManager) -> void:
	_score_point(_get_opponent_player(playerManger.player_id))
