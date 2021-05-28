extends RayCast

var _max_distance := Constants.ranged_attack_type.attack_range

func _ready():
	for child in get_children():
		child.points = [Vector3.ZERO, Vector3.ZERO]
		child.material_override = preload("res://Players/VisibilityMaterial.tres").duplicate()

func _physics_process(delta):
	cast_to= Vector3(0,0,-_max_distance)
	var collider = get_collider()
	var hitpoint = get_collision_point()
	var distance = _max_distance;
	if collider:
		var hit_distance = hitpoint.distance_to(global_transform.origin)
		if hit_distance < distance:
			distance = hit_distance
	
	for child in get_children():
		child.points[1]=Vector3(0,0,-distance)
