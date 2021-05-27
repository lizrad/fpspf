extends Area

export var only_hit_one_body = true
var _damage := 10.0
var _attack_time := 2.00
var _owning_player
var _hit_something = false
func initialize_visual(owning_player, attack_time, attack_range) ->void:
	_attack_time = attack_time
	$Visualization.scale = Vector3(attack_range,attack_range,attack_range)
	$Visualization.set_surface_material(0, owning_player.get_parent().shot_material)
	
func initialize(owning_player, attack_time, attack_range, damage) ->void:
	_damage = damage
	_owning_player = owning_player
	var sphereShape = SphereShape.new()
	sphereShape.radius = attack_range
	$CollisionShape.shape = sphereShape
	initialize_visual(owning_player, attack_time, attack_range)
	
func _process(delta):
	if(_attack_time<=0):
		queue_free()
		return
	_attack_time-=delta

func _hit_body(body) ->void:
	if body.is_in_group("Damagable"):
			assert(body.has_method("receive_damage"))
			print(str("Melee attack hit body named ",body.name))
			_hit_something = true
			body.receive_damage(_damage)

func _physics_process(delta):
	var bodies =  get_overlapping_bodies()
	if bodies.size() == 0:
		return
	if only_hit_one_body:
		if _hit_something:
			return
		var nearest_body
		var nearest_distance = INF
		for body in bodies:
			if _hit_something:
				return
			if not body.is_in_group("Damagable"):
				continue
			if body == _owning_player:
				continue
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_body = body
		if nearest_body == null:
			return
		_hit_body(nearest_body)
	else:
		var other_player
		print("hit bodies size "+str(bodies.size()))
		for body in bodies:
			if not body.is_in_group("Damagable"):
				continue
			if body == _owning_player:
				continue
			print("hit "+body.name)
			# make sure we hit other player last
			if body.is_player():
				print ("found other player")
				other_player = body
				continue
			_hit_body(body)
		if other_player:
			print ("hit other player")
			_hit_body(other_player)
