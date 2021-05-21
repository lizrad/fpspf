extends Control

var _prep_time = true
var _cycle := 0
#var scores[]


func _ready():
	#$Cycle.visible = false
	pass


func set_time(time):
	var seconds = int(time)
	$Timer.set_text("{mm}:{ss}".format({
						 "mm":"%02d" % (seconds / 60),
						 "ss":"%02d" % (seconds % 60)}))


func set_score(idx_player, score):
	var label_score = $Score1 if idx_player == 0 else $Score1
	label_score.set_text(str(score))


func _update_cycle_text():
	var text = "Preparation phase " if _prep_time else " "
	text += "Cycle " + str(_cycle)
	$Cycle.set_text(text)


func set_cycle(cycle):
	_cycle = cycle
	_update_cycle_text()


func set_prep_time(active):
	_prep_time = active
	_update_cycle_text()
