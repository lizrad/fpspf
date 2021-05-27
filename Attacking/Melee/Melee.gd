extends Area

export var hit_sphere_radius := 1.0
export var active_time = 0.1
var _damage := 10.0
var _visualization_time := 2.00
var _owning_player
var _hit_something = false
func initialize_visual(owning_player, visualization_time) ->void:
	_visualization_time = visualization_time
	$Visualization.scale = Vector3(hit_sphere_radius,hit_sphere_radius,hit_sphere_radius)
	$Visualization.set_surface_material(0, owning_player.get_parent().shot_material)
	
func initialize(owning_player, visualization_time, damage) ->void:
	assert(visualization_time>=active_time) #the attack should not be longer active than it is visualized
	_damage = damage
	_owning_player = owning_player
	var sphereShape = SphereShape.new()
	sphereShape.radius = hit_sphere_radius
	$CollisionShape.shape = sphereShape
	initialize_visual(owning_player, visualization_time)
	
func _process(delta):
	active_time-=delta;
	if(_visualization_time<=0):
		queue_free()
		return
	_visualization_time-=delta


func _on_Melee_body_entered(body):
	if active_time <= 0 or _hit_something:
		return
	if body != _owning_player: 
		if body.is_in_group("Damagable"):
			assert(body.has_method("receive_damage"))
			print(str("Melee attack hit body named ",body.name))
			_hit_something = true
			body.receive_damage(_damage)
			active_time = 0 #only hit max one enemy with each attack
