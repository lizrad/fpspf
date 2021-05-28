extends KinematicBody
class_name CharacterBase


var id: int = -1 setget set_id, get_id
var visibility_mask: ViewportTexture
var invincible := true # does not loose hp

var _current_health := 3
var _dead = false

var _health_position : Vector3


func _ready():
	$Attacker.set_owning_player(self)
	_health_position = $HealthDisplay.translation
	
func _physics_process(delta):
	$HealthDisplay.global_transform = global_transform
	$HealthDisplay.global_transform.origin += _health_position
	
	#visibility_mask.get_data().save_png("res://tex%s.png" % [id])


func _set_visible_instance_layers(object, id, default=0):
	object.layers = default
	object.set_layer_mask_bit(id, true)


func set_visibility_mask(mask: ViewportTexture):
	visibility_mask = mask
	$MeshInstance.material_override.set_shader_param("visibility_mask", mask)
	$Attacker.set_visibility_mask(mask)
	
	# White mask for own mesh
	var own_mask = Image.new()
	own_mask.create(1, 1, false, Image.FORMAT_RGBA8)
	own_mask.lock()
	own_mask.set_pixel(0, 0, Color(1.0, 1.0, 1.0, 1.0))
	own_mask.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(own_mask)
	
	$OwnMeshInstance.material_override = load("res://Players/VisibilityMaterial.tres").duplicate()
	$OwnMeshInstance.material_override.set_shader_param("visibility_mask", tex)
	$OwnMeshInstance.material_override.set_shader_param("color", Constants.character_colors[id])


func get_used_visibility_mask():
	return visibility_mask


func set_rendering_for_character_id(id):
	$Attacker.set_render_layer_for_player_id(id)
	
	_set_visible_instance_layers($MeshInstance, Constants.PLAYER_GENERAL)
	_set_visible_instance_layers($OwnMeshInstance, 5 + id)
	_set_visible_instance_layers($HealthDisplay, 5 + id)
	_set_visible_instance_layers($VisibilityLights/OmniLight, 5 + id)
	_set_visible_instance_layers($VisibilityLights/SightLight, 5 + id)
	
	$MeshInstance.material_override.set_shader_param("color", Constants.character_colors[id])


func get_id():
	return id

func is_player() ->bool:
	return id<=Constants.CharacterID.PLAYER_4
	
func set_id(new_id):
	id = new_id
	set_rendering_for_character_id(id)

func receive_damage(damage: float):
	$HitParticles.emitting=true
	$HitSound.play()

func _show_dead():
	_dead = true
	rotation.z = PI / 2
	$CollisionShape.disabled = true
	$Attacker.visible = false
	$VisibilityLights.set_enabled(false)
	$DeathSound.play()

func set_current_health(new_health):
	_current_health = new_health
	
	# Reset health bar
	for child in $HealthDisplay/Viewport/HealthBar.get_children():
		child.visible = false
	
	# Set appropriate amount of hearts as active
	for i in range(new_health):
		$HealthDisplay/Viewport/HealthBar.get_child(i).visible = true
