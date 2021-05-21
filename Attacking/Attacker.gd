extends Spatial

export var ranged_attack_type: Resource
export var melee_attack_type: Resource
export var visualization_time := 0.5
var _attack_deadline := 0.0

func Shoot() -> void:
	if _attack_deadline <= 0:
		_create_attack(ranged_attack_type)

func Melee() -> void:
	if _attack_deadline <= 0:
		_create_attack(melee_attack_type)
		
func _process(delta):
	if _attack_deadline > 0:
		_attack_deadline -= delta

func _create_attack(attack_type) -> void:
	_attack_deadline = attack_type.cooldown
	var attack = attack_type.attack.instance()
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize(visualization_time, attack_type.damage)
