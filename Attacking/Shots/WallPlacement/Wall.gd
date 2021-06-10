extends StaticBody


var placed_by_body


func _ready():
	$KillGhostArea.connect("body_entered", self, "_hit_body")


func initialize(owning_player, attack_type) -> void:
	initialize_visual(owning_player, attack_type)


func initialize_visual(owning_player, attack_type) ->void:
	$MeshInstance.material_override.albedo_color = Constants.character_colors[owning_player.id]


func _hit_body(body) ->void:
	if body is Ghost and body != placed_by_body:
		body.die()
