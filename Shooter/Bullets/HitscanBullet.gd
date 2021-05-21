extends RayCast

export var bullet_range := 50.0

var _visualization_time # Set from the Shooter

var _damage := 10.0
var _first_frame := true

func initialize(visualization_time, damage) ->void:
	_damage = damage
	_visualization_time = visualization_time
	cast_to = Vector3(0,0,-bullet_range)
	
	$LineRenderer.points = []
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.points.append(Vector3.ZERO)
	
	_update_collision()
	
func _physics_process(delta):
	_visualization_time -= delta
	
	if(_visualization_time<=0):
		queue_free()
		return
	
	if _first_frame:
		_update_collision()
		_first_frame = false


func _update_collision():
	var collider = get_collider()
	if collider:
		print(str("Bullet hit collider of node named ",collider.name))
		
		# Update the line renderer no matter what it is
		$LineRenderer.points[1] = to_local(get_collision_point())
		
		# Shoot player if it was shootable
		if collider.is_in_group("Shootable"):
			assert(collider.has_method("Shot"))
			collider.Shot(_damage)
