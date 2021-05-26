extends Spatial

export var visualization_time := 0.5
var _attack_deadline := 0.0

var _ammunition_tracker = {}
var _owning_player;
signal shot_bullet

func set_owning_player(player)->void:
	_owning_player = player
	$AttackOriginPosition/AimVisualization/LineRenderer.material_override = player.get_parent().laser_material

func visualize_attack(attack_type, owning_player) ->void:
	var attack = attack_type.attack.instance()
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize_visual(owning_player, visualization_time)

	
func attack(attack_type, owning_player) -> bool:
	if _attack_deadline <= 0:
		return _create_attack(attack_type, owning_player)
	return false


func set_render_layer_for_player_id(player_id) -> void:
	$AttackOriginPosition/AimVisualization/LineRenderer.layers = 0
	$AttackOriginPosition/AimVisualization/LineRenderer.set_layer_mask_bit(5 + player_id, true)


func reload(attack_type) -> void:
	_ammunition_tracker[attack_type]=attack_type.ammunition

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
		emit_signal("shot_bullet")
	return true


func _create_attack(attack_type, owning_player) -> bool:
	if !_handle_ammunition(attack_type):
		return false
	print(str("Ammunition is ",_ammunition_tracker[attack_type], "/",attack_type.ammunition))
	_attack_deadline = attack_type.cooldown
	var attack = attack_type.attack.instance()
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize(owning_player, visualization_time, attack_type.damage)
	return true
