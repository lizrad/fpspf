extends RayCast

export var bullet_range := 50.0

var _visualization_time # Set from the Shooter
var _owning_player;
var _damage := 10.0
var _first_frame := true
var _visual := false

func initialize_visual(owning_player, visualization_time) ->void:
	_visual = true
	cast_to = Vector3(0,0,-bullet_range)
	_visualization_time = visualization_time
	$LineRenderer.points = []
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.points.append(Vector3.ZERO)
	_owning_player = owning_player
	add_exception(owning_player)
	
func initialize(owning_player, visualization_time, damage) ->void:
	_damage = damage
	cast_to = Vector3(0,0,-bullet_range)
	_visualization_time = visualization_time
	$LineRenderer.points = []
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.material_override = owning_player.get_parent().shot_material
	_update_collision()
	
func _physics_process(delta):
	_visualization_time -= delta
	
	if(_visualization_time<=0):
		queue_free()
		return
	
	if _first_frame:
		_first_frame = false
		if _visual:
			var collider = get_collider()
			if collider:
				$LineRenderer.points[1]=to_local(get_collision_point())
			$LineRenderer.material_override = _owning_player.get_parent().shot_material
		else:
			_update_collision()


func _update_collision():
	var collider = get_collider()
	if collider:
		print(str("Bullet hit collider of node named ",collider.name))
		
		# Update the line renderer no matter what it is
		$LineRenderer.points[1] = to_local(get_collision_point())
		
		# Shoot player if it was damagable
		if collider.is_in_group("Damagable"):
			assert(collider.has_method("receive_damage"))
			collider.receive_damage(_damage)
