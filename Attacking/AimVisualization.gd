extends RayCast

var _max_distance := Constants.ranged_attack_type.attack_range

func _ready():
	$LineRenderer.points = [Vector3.ZERO, Vector3.ZERO]

func _physics_process(delta):
	cast_to= Vector3(0,0,-_max_distance)
	var collider = get_collider()
	var hitpoint = get_collision_point()
	var distance = _max_distance;
	if collider:
		var hit_distance = hitpoint.distance_to(global_transform.origin)
		if hit_distance < distance:
			distance = hit_distance
	$LineRenderer.points[1]=Vector3(0,0,-distance)
