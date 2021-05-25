extends Control

var _prep_time := true
var _cycle := 0
var _num_cycles := 0


func set_time(time):
	var seconds = int(time)
	$Timer.set_text("{mm}:{ss}".format({
						 "mm":"%02d" % (seconds / 60),
						 "ss":"%02d" % (seconds % 60)}))


# update score for opponent
func set_score(idx_player, score):
	var label_score = $Score1 if idx_player == 0 else $Score2
	label_score.set_text(str(score))


func _update_cycle_text():
	var text = "Preparation phase " if _prep_time else "Cycle "
	text += str(_cycle) + " of " + str(_num_cycles)
	$Cycle.set_text(text)


# update ammo for current
func consume_bullet(idx_player):
	var bullet_ammo = $BulletAmmo2 if idx_player == 0 else $BulletAmmo1
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


func set_prep_time(active):
	if _prep_time != active:
		_prep_time = active
		_update_cycle_text()
