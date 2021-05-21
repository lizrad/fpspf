extends RayCast

var _damage
var _visualization_time
var _first_frame = true

func initialize(visualization_time, speed, damage, bullet_range) ->void:
	_damage = damage
	_visualization_time = visualization_time
	cast_to = Vector3(0,0,-bullet_range)
	$LineRenderer.points.clear();
	$LineRenderer.points.append(Vector3.ZERO);
	$LineRenderer.points.append(Vector3(0,0,-bullet_range));
	
func _process(delta):
	if(_visualization_time<=0):
		queue_free()
		return
	_visualization_time-=delta
	
	
func _physics_process(delta):
	if not _first_frame:
		return
	_first_frame = false
	var collider = get_collider()
	if collider: 
		print(str("Bullet hit collider of node named ",collider.name))
		if collider.is_in_group("Shootable"):
			assert(collider.has_method("Shot"))
			collider.Shot(_damage)
	else:
		print("Bullet hit nothing")
