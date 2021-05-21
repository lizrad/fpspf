extends Spatial

export var visualization_time := 0.5
var _attack_deadline := 0.0

var _ammunition_tracker = {}

func attack(attack_type, owning_player) -> void:
	if _attack_deadline <= 0:
		_create_attack(attack_type, owning_player)

func _process(delta):
	if _attack_deadline > 0:
		_attack_deadline -= delta
func _handle_ammunition(attack_type) ->bool:
	if not _ammunition_tracker.has(attack_type):
		_ammunition_tracker[attack_type]=attack_type.ammunition
		
	if _ammunition_tracker[attack_type]==0:
		return false
	elif _ammunition_tracker[attack_type]>0:
		_ammunition_tracker[attack_type]-=1
		
	return true

func _create_attack(attack_type, owning_player) -> void:
	if !_handle_ammunition(attack_type):
		return
	print(str("Ammunition is ",_ammunition_tracker[attack_type], "/",attack_type.ammunition))
	_attack_deadline = attack_type.cooldown
	var attack = attack_type.attack.instance()
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize(owning_player, visualization_time, attack_type.damage)
