extends Area

export var hit_sphere_radius := 1.0
export var active_time = 0.1
var _damage := 10.0
var _visualization_time := 2.00
var _owning_player

func initialize(owning_player, visualization_time, damage) ->void:
	print("Melee")
	assert(visualization_time>=active_time) #the attack should not be longer active than it is visualized
	_damage = damage
	_owning_player = owning_player
	_visualization_time = visualization_time
	var sphereShape = SphereShape.new()
	sphereShape.radius = hit_sphere_radius
	$CollisionShape.shape = sphereShape
	$Visualization.scale = Vector3(hit_sphere_radius,hit_sphere_radius,hit_sphere_radius);
	
func _process(delta):
	active_time-=delta;
	if(_visualization_time<=0):
		queue_free()
		return
	_visualization_time-=delta


func _on_Melee_body_entered(body):
	if active_time <= 0:
		return
	if body != _owning_player: 
		if body.is_in_group("Damagable"):
			assert(body.has_method("receive_damage"))
			print(str("Melee attack hit body named ",body.name))
			body.receive_damage(_damage)
			active_time = 0 #only hit max one enemy with each attack
