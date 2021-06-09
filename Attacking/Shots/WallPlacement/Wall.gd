extends StaticBody


func initialize(owning_player, attack_type) -> void:
	initialize_visual(owning_player, attack_type)


func initialize_visual(owning_player, attack_type) ->void:
	$MeshInstance.material_override.albedo_color = Constants.character_colors[owning_player.id]
