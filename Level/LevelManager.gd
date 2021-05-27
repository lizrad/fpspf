extends Spatial

var _player_base_1
var _player_base_2

func open_doors():
	$Level/SpawnArea1.open_doors()
	$Level/SpawnArea2.open_doors()
	
func close_doors():
	($Level/SpawnArea1 as SpawnArea).close_doors()
	($Level/SpawnArea2 as SpawnArea).close_doors()
