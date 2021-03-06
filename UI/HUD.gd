extends Control

export (Array, NodePath) var capture_points := [] 

export (Array, NodePath) var capture_points_progress_bars := []

var _gamestate = Constants.Gamestate.PREP
var _cycle := 0
var _num_cycles := 0

func _ready() -> void:
	$Score1.add_color_override("font_color", Constants.character_colors[0])
	$Score1.add_color_override("font_outline_modulate", Constants.character_colors[0])
	$Score2.add_color_override("font_color", Constants.character_colors[1])
	$Score2.add_color_override("font_outline_modulate", Constants.character_colors[1])


func set_time(time):
	var seconds = int(time)
	$Timer.set_text("{mm}:{ss}".format({
						 "mm":"%02d" % (seconds / 60),
						 "ss":"%02d" % (seconds % 60)}))


func set_player_attack_type(idx_player: int, attack_type: Resource):
	var bullet_ammo = $BulletAmmo1 if idx_player == 0 else $BulletAmmo2
	bullet_ammo.attack_type = attack_type
	bullet_ammo.init()
	print(attack_type.ammunition)


func set_score(idx_player, score):
	var label_score = $Score1 if idx_player == 0 else $Score2
	label_score.set_text(str(score))


func _update_cycle_text():
	var text
	match _gamestate:
		Constants.Gamestate.PREP:
			text = "Preperation"
		Constants.Gamestate.GAME:
			text = "Cycle "
			text += str(_cycle) + " of " + str(_num_cycles)
		Constants.Gamestate.REPLAY:
			text = "Replay"
	$Cycle.set_text(text)


func regain_bullet(idx_player):
	var bullet_ammo = $BulletAmmo1 if idx_player == 0 else $BulletAmmo2
	bullet_ammo.add_bullet()

func consume_bullet(idx_player):
	var bullet_ammo = $BulletAmmo1 if idx_player == 0 else $BulletAmmo2
	bullet_ammo.remove_bullet()


func reload_ammo():
	$BulletAmmo1.reload()
	$BulletAmmo2.reload()


func set_cycle(cycle):
	if _cycle != cycle:
		_cycle = cycle
		_update_cycle_text()


func set_num_cycles(num_cycles):
	if _num_cycles != num_cycles:
		_num_cycles = num_cycles
		_update_cycle_text()

func set_game_state(gamestate):
	_gamestate = gamestate
	_update_cycle_text()


func _hide_all():
	for child in get_children():
		child.visible = false


func _show_all():
	for child in get_children():
		child.visible = true


func set_winner(idx: int):
	$GameOverScreen.set_winner(idx)


func toggle_game_over_screen(active: bool):
	if not active:
		_show_all()
	else:
		_hide_all()
	if active:
		$GameOverScreen.show()
	else:
		$GameOverScreen.hide()


func update_capture_point_ui(capture_point_index : int, progress : float):
	if(capture_point_index < 3):
		get_node(capture_points[capture_point_index]).value = progress * 100

func update_capture_point_ui_bar(captured_points_array : Array, capture_point_number : float):
	get_node(capture_points_progress_bars[0]).value = (captured_points_array[0] / capture_point_number) * 100
	get_node(capture_points_progress_bars[1]).value = (captured_points_array[1] / capture_point_number) * 100

func set_capture_point_color(capture_point_index : int, color : Color):
	get_node(capture_points[capture_point_index]).tint_progress = color

func set_max_cap_percent(percent : float):
	for idx_bar in capture_points_progress_bars.size():
		var progress_bar = get_node(capture_points_progress_bars[idx_bar])
		var prog_width = progress_bar.rect_size.x
		var sprite = progress_bar.get_node("triangle")
		sprite.modulate = Constants.character_colors[idx_bar]
		# TODO FIXME: how to use FillMode enums? or calc from ints
		if progress_bar.fill_mode == 0: # FILL_LEFT_TO_RIGHT
			sprite.position.x = prog_width * percent
		elif progress_bar.fill_mode == 1: # FILL_RIGHT_TO_LEFT:
			sprite.position.x = prog_width - prog_width * percent
