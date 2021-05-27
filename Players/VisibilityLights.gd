extends Spatial


func _ready():
	$SightLight.spot_range = Constants.view_distance
	$OmniLight.omni_range = Constants.circular_view_radius
