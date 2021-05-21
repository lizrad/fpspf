extends Area

export var hit_sphere_radius := 1.0
export var active_time = 0.5
var _damage := 10.0
var _visualization_time := 2.0

func _ready():
	initialize(100,1);

func initialize(visualization_time, damage) ->void:
	assert(visualization_time>=active_time) #the attack should not be longer active than it is visualized
	_damage = damage
	_visualization_time = visualization_time
	var sphereShape = SphereShape.new()
	sphereShape.radius = hit_sphere_radius
	$CollisionShape.shape = sphereShape
	
func _process(delta):
	active_time-=delta;
	if(_visualization_time<=0):
		queue_free()
		return
	_visualization_time-=delta


func _on_Melee_body_entered(body):
	if active_time <= 0:
		return
	print(str("Melee attack hit body named ",body.name))
	if body.is_in_group("Shootable"):
		assert(body.has_method("Shot"))
		body.Shot(_damage)
