extends KinematicBody
class_name CharacterBase


var id: int = -1 setget set_id, get_id

export(Array, Color) var character_colors = [
	Color(1.0, 0.0, 0.0), # Player 1
	Color(0.0, 0.0, 1.0), # Player 2
	Color(0.0, 0.0, 1.0), # Player 3
	Color(0.0, 0.0, 1.0), # Player 4
	Color(0.2, 0.6, 0.2), # Ghosts
]

enum CharacterID {
	PLAYER_1 = 0,
	PLAYER_2 = 1,
	PLAYER_3 = 2,
	PLAYER_4 = 3,
	GHOST = 4
}

const PLAYER_GENERAL = 1

func _ready():
	$Attacker.set_owning_player(self)

func _set_visible_instance_layers(object, id, default=0):
	object.layers = default
	object.set_layer_mask_bit(id, true)


func set_visibility_mask(mask: ViewportTexture):
	$MeshInstance.material_override.set_shader_param("visibility_mask", mask)


func set_rendering_for_character_id(id):
	$Attacker.set_render_layer_for_player_id(id)
	
	_set_visible_instance_layers($MeshInstance, PLAYER_GENERAL)
	_set_visible_instance_layers($VisibilityLights/OmniLight, 5 + id)
	_set_visible_instance_layers($VisibilityLights/SightLight, 5 + id)
	
	$MeshInstance.material_override.set_shader_param("color", character_colors[id])


func get_id():
	return id

func set_id(new_id):
	id = new_id
	set_rendering_for_character_id(id)
