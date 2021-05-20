extends Spatial

var _player_base_1
var _player_base_2

func open_doors():
	$Level/PlayerBase1.open_doors()
	$Level/PlayerBase2.open_doors()
	#($PlayerBase1 as PlayerBase).open_doors()
	
func close_doors():
	($Level/PlayerBase1 as PlayerBase).close_doors()
	($Level/PlayerBase2 as PlayerBase).close_doors()
