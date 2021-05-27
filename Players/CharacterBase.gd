extends KinematicBody
class_name CharacterBase


var id: int = -1 setget set_id, get_id

func _ready():
	$Attacker.set_owning_player(self)

func _set_visible_instance_layers(object, id, default=0):
	object.layers = default
	object.set_layer_mask_bit(id, true)


func set_visibility_mask(mask: ViewportTexture):
	$MeshInstance.material_override.set_shader_param("visibility_mask", mask)


func set_rendering_for_character_id(id):
	$Attacker.set_render_layer_for_player_id(id)
	
	_set_visible_instance_layers($MeshInstance, Constants.PLAYER_GENERAL)
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
