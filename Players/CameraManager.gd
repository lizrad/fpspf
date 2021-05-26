extends Spatial

export var height := 50.0


func _ready():
	$LightCamera/Viewport.size = $ViewCamera/ViewportContainer/Viewport.size
	
	if get_parent().id == 1:
		$ViewCamera/ViewportContainer.rect_position.x += 512


func _process(delta):
	var new_origin = global_transform.origin + Vector3(0.0, height, 0.0)
	
	# TODO: Nice lerped movement
	$LightCamera/Viewport/Camera.global_transform.origin = new_origin
	$ViewCamera/ViewportContainer/Viewport/Camera.global_transform.origin = new_origin
