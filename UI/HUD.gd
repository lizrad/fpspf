extends Control

var score1
var score2

var cycle


func _ready():
	$Cycle.visible = false


func set_time(time):
	var seconds = int(time)
	$Timer.set_text("{mm}:{ss}".format({
						 "mm":"%02d" % (seconds / 60),
						 "ss":"%02d" % (seconds % 60)}))


func set_score(idx_player, score):
	var label_score = $Score1 if idx_player == 0 else $Score1
	label_score.set_text(str(score))


func set_cycle(cycle):
	$Cycle.set_text("Cycle " + str(cycle))
	$Cycle.visible = cycle != 0
