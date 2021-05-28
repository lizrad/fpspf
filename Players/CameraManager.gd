extends Spatial

export var height := Constants.player_camera_height
var fov := Constants.player_camera_fov


func _ready():
	if get_parent().id == 1:
		$ViewCamera/ViewportContainer.rect_position.x += 544


func _process(delta):
	var new_origin = global_transform.origin + Vector3(0.0, height, 0.0)
	
	# TODO: Nice lerped movement
	$LightCamera/Viewport/Camera.global_transform.origin = Vector3.ZERO
	$ViewCamera/ViewportContainer/Viewport/Camera.global_transform.origin = new_origin
	$ViewCamera/ViewportContainer/Viewport/Camera.fov = fov
