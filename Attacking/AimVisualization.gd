extends RayCast

export var max_distance := 3

func _ready():
	cast_to= Vector3(0,0,-max_distance)

func _process(delta):
	var collider = get_collider()
	print(collider)
	var hitpoint = get_collision_point()
	var distance = max_distance;
	if collider:
		print(hitpoint)
		var hit_distance = hitpoint.distance_to(global_transform.origin)
		print(hit_distance)
		if hit_distance < distance:
			distance = hit_distance
	$LineRenderer.points[1]=Vector3(0,0,-distance)
