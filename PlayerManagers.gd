extends Spatial


func _ready():
	$PlayerManager1.active_player.set_visibility_mask($PlayerManager2.active_player.get_visibility_mask())
	$PlayerManager2.active_player.set_visibility_mask($PlayerManager1.active_player.get_visibility_mask())
