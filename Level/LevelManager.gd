extends Spatial

var _player_base_1
var _player_base_2

func open_doors():
	($PlayerBase1 as PlayerBase).open_doors()
	
func close_doors():
	($PlayerBase1 as PlayerBase).close_doors()
