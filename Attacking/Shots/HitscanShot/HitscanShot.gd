extends RayCast

var _continuosly_damaging
var _damage_invincibility_time
var _bullet_range 
var _attack_time # Set from the Shooter
var _owning_player;
var _damage := 10.0
var _bounce_strength := 50.0
var _visual := false
var _first_frame := true

var _hit_bodies_invincibilty_tracker = {}

var _attack_type_type

func initialize_visual(owning_player, attack_type) ->void:
	_visual = true
	_bullet_range = attack_type.attack_range
	cast_to = Vector3(0,0,-_bullet_range)
	_attack_time = attack_type.attack_time
	$LineRenderer.points = []
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.points.append(Vector3.ZERO)
	_owning_player = owning_player
	add_exception(owning_player)
	
func initialize(owning_player, attack_type) ->void:
	_damage = attack_type.damage
	_bounce_strength = attack_type.bounce_strength
	_bullet_range = attack_type.attack_range
	_continuosly_damaging = attack_type.continuously_damaging
	_damage_invincibility_time = attack_type.damage_invincibility_time
	cast_to = Vector3(0,0,-_bullet_range)
	_attack_time = attack_type.attack_time
	_owning_player = owning_player
	_attack_type_type = attack_type.attack_type_type
	$LineRenderer.points = []
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.points.append(Vector3.ZERO)
	$LineRenderer.material_override.albedo_color = Constants.character_colors[_owning_player.id]
	_update_collision()
	
func _physics_process(delta):
	_attack_time -= delta
	
	if(_attack_time<=0):
		queue_free()
		return
	for i in _hit_bodies_invincibilty_tracker.keys():
		_hit_bodies_invincibilty_tracker[i]-=delta
		_hit_bodies_invincibilty_tracker[i] = clamp(_hit_bodies_invincibilty_tracker[i],0,_damage_invincibility_time)
	if _visual or (not _first_frame and not _continuosly_damaging):
		var collider = get_collider()
		if collider:
			var hit_point = to_local(get_collision_point())
			$LineRenderer.points[1] = hit_point if hit_point.length()<_bullet_range else Vector3(0,0,-_bullet_range)
		else:
			$LineRenderer.points[1] = Vector3(0,0,-_bullet_range)
			
		$LineRenderer.material_override.albedo_color = Constants.character_colors[_owning_player.id]
	elif _continuosly_damaging or _first_frame:
		_first_frame = false
		_update_collision()


func _update_collision():
	var collider = get_collider()
	if collider:
		
		# Update the line renderer no matter what it is
		
		var hit_point = to_local(get_collision_point())
		$LineRenderer.points[1] = hit_point if hit_point.length()<_bullet_range else Vector3(0,0,-_bullet_range)
		
		# Shoot player if it was damagable
		if collider.is_in_group("Damagable"):
			assert(collider.has_method("receive_hit"))
			if (not _hit_bodies_invincibilty_tracker.has(collider) or _hit_bodies_invincibilty_tracker[collider] <=0):
				_hit_bodies_invincibilty_tracker[collider]=_damage_invincibility_time
				collider.receive_hit(_attack_type_type, _damage,-transform.basis.z*_bounce_strength)
	else:
		$LineRenderer.points[1] = Vector3(0,0,-_bullet_range)
