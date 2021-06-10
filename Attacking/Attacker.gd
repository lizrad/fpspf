extends Spatial

var _attack_deadline := 0.0
var _spawned_attacks = []

var _ammunition_tracker = {}
var _owning_player

signal shot_bullet
signal gain_bullet
signal fired_burst_shot

func set_owning_player(player)->void:
	_owning_player = player
	$AttackOriginPosition/AimVisualization/LineRenderer.material_override.set_shader_param(
		"color",
		Constants.character_colors[_owning_player.id]
	)
	$AttackOriginPosition/AimVisualization/LineRenderer2.material_override.set_shader_param(
		"color",
		Constants.character_colors[_owning_player.id]
	)


func set_visibility_mask(mask):
	$AttackOriginPosition/AimVisualization/LineRenderer.material_override.set_shader_param(
		"visibility_mask",
		mask
	)
	
	# White mask for own mesh
	var own_mask = Image.new()
	own_mask.create(1, 1, false, Image.FORMAT_RGBA8)
	own_mask.lock()
	own_mask.set_pixel(0, 0, Color(1.0, 1.0, 1.0, 1.0))
	own_mask.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(own_mask)
	
#	$AttackOriginPosition/AimVisualization/LineRenderer2.material_override.set_shader_param(
#		"visibility_mask",
#		tex
#	)


func visualize_attack(attack_type, owning_player) -> void:
	var attack = attack_type.attack.instance()
	_spawned_attacks.append(attack)
	attack.connect("tree_exiting", self, "_attack_tree_exiting", [attack])
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize_visual(owning_player, attack_type)
	emit_signal("gain_bullet")


func attack(attack_type, owning_player) -> bool:
	if _attack_deadline <= 0:
		if !_handle_ammunition(attack_type):
			return false

		for i in range(attack_type.burst_amount):
			_create_attack(i*attack_type.burst_delay,attack_type, owning_player)
		return true
	return false


func set_render_layer_for_player_id(player_id) -> void:
	$AttackOriginPosition/AimVisualization/LineRenderer.layers = 0
	$AttackOriginPosition/AimVisualization/LineRenderer.set_layer_mask_bit(Constants.PLAYER_GENERAL, true)
	$AttackOriginPosition/AimVisualization/LineRenderer2.layers = 0
	$AttackOriginPosition/AimVisualization/LineRenderer2.set_layer_mask_bit(5 + player_id, true)


func reload(attack_type) -> void:
	_ammunition_tracker[attack_type]=attack_type.ammunition

func reload_all() ->void:
	for attack_type in _ammunition_tracker:
		reload(attack_type)

func reset()->void:
	for attack in _spawned_attacks:
		attack.queue_free()
	_spawned_attacks.clear()
		

func _process(delta):
	if _attack_deadline > 0:
		_attack_deadline -= delta


func _handle_ammunition(attack_type) -> bool:
	if not _ammunition_tracker.has(attack_type):
		_ammunition_tracker[attack_type] = attack_type.ammunition

	if _ammunition_tracker[attack_type] == 0:
		return false

	elif _ammunition_tracker[attack_type] > 0:
		_ammunition_tracker[attack_type] -= 1
		emit_signal("shot_bullet")
	return true


func _create_attack(wait_time, attack_type, owning_player) ->void:
	yield(get_tree().create_timer(wait_time), "timeout")
	_attack_deadline = attack_type.cooldown
	var attack = attack_type.attack.instance()
	_spawned_attacks.append(attack)
	attack.connect("tree_exiting", self, "_attack_tree_exiting", [attack])
	attack.set("placed_by_body", owning_player) # only used by walls now
	get_tree().get_root().add_child(attack);
	attack.global_transform = global_transform
	attack.global_transform.origin = $AttackOriginPosition.global_transform.origin;
	attack.initialize(owning_player, attack_type)
	
	emit_signal("fired_burst_shot", attack_type)
	if attack_type.sound != null:
		$SoundPlayer.stream = attack_type.sound
		$SoundPlayer.play()
	# FIXME: remove default player
	else:
		$PewSound.play()


func _attack_tree_exiting(attack) ->void:
	_spawned_attacks.remove(_spawned_attacks.find(attack))
