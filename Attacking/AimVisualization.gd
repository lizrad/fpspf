extends RayCast

var _max_distance =0


func set_max_distance(max_distance) ->void:
	_max_distance = max_distance
	cast_to= Vector3(0,0,-_max_distance)
	
func _physics_process(delta):
	var collider = get_collider()
	var hitpoint = get_collision_point()
	var distance = _max_distance;
	if collider:
		var hit_distance = hitpoint.distance_to(global_transform.origin)
		if hit_distance < distance:
			distance = hit_distance
	$LineRenderer.points[1]=Vector3(0,0,-distance)
