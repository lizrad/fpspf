extends Spatial

export var shooter_type: Resource
export var visualization_time = 2.0
var _shooting_deadline := 0.0
var _hitscan_bullet_scene = preload("res://Shooter/Bullets/HitscanBullet.tscn")

func _ready():
	#Shoot()
	pass

func Shoot() -> void:
	print(_shooting_deadline)
	if _shooting_deadline <= 0:
		_spawn_bullet()
	
	
func _process(delta):
	if _shooting_deadline > 0:
		_shooting_deadline -= delta

func _spawn_bullet() -> void:
	_shooting_deadline = shooter_type.cooldown
	var bullet
	match shooter_type.bullet_type:
		shooter_type.BulletType.Hitscan:
			bullet = _hitscan_bullet_scene.instance();
		# TODO: create and handle other bullet types
	get_tree().root.add_child(bullet);
	bullet.global_transform *= global_transform
	bullet.global_transform.origin = $BulletSpawnPosition.global_transform.origin;
	bullet.call_deferred("initialize", visualization_time, shooter_type.bullet_speed, shooter_type.damage, shooter_type.bullet_range)
