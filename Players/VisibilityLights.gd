extends Spatial


func _ready():
	$SightLight.spot_range = Constants.view_distance
	$OmniLight.omni_range = Constants.circular_view_radius
	$SightLight.spot_angle = Constants.view_angle


func set_enabled(is_enabled):
	$SightLight.visible = is_enabled
	$OmniLight.visible = is_enabled
