extends Spatial

export var visualization_time := 0.5
var _attack_deadline := 0.0

func attack(attack_type, owning_player) -> void:
	if _attack_deadline <= 0:
		_create_attack(attack_type, owning_player)

func _process(delta):
	if _attack_deadline > 0:
		_attack_deadline -= delta

func _create_attack(attack_type, owning_player) -> void:
	_attack_deadline = attack_type.cooldown
	var attack = attack_type.attack.instance()
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize(owning_player, visualization_time, attack_type.damage)
