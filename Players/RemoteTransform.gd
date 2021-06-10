extends RemoteTransform


export(NodePath) var camera_path


func _ready():
	if Constants.first_person:
		get_node(camera_path).transform = Transform.IDENTITY
		remote_path = camera_path
