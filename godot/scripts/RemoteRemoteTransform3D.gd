class_name RemoteRemoteTransform3D extends Node3D

## Modeled to function like [RemoteTransform3D] except applying the remote's transform onto this node.
## Optionally we can target a node other than self by using [member target].

@export_node_path("Node3D") var remote_path:NodePath
@export var force_remote_to_current_camera:bool = false ## If true, uses the [method Viewport.get_current_camera] as the remote node.
@export var target: Node3D
@export var use_global_coordinates: bool = true

@export_group("Update", "update_")
@export var update_position: bool = true ## If true, the [member target]'s position.
@export var update_rotation: bool = true ## If true, the [member target]'s rotation.
@export var update_scale: bool = true ## If true, the [member target]'s scale.

func _process(delta: float) -> void:
	var remote: Node3D
	if force_remote_to_current_camera:
		remote = get_viewport().get_camera_3d()
	elif remote_path:
		remote = get_node_or_null(remote_path)
		
	if remote:
		if not target:
			target = self
		elif not target.is_inside_tree():
			return
			
		if update_position:
			if use_global_coordinates:
				target.global_position = remote.global_position
			else:
				target.position = remote.position
		if update_rotation:
			if use_global_coordinates:
				target.global_rotation = remote.global_rotation
			else:
				target.rotation = remote.rotation
		if update_scale:
			target.scale = remote.scale
