extends Node3D

@export var return_scene: PackedScene

@export var music: DynamicMusicTrack

@onready var camera_marker: Marker3D = %CameraMarker3D
@onready var remote_transform_3d: RemoteTransform3D = %RemoteTransform3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var credits: CanvasLayer = $Credits

func _ready() -> void:
	#await get_tree().process_frame
	remote_transform_3d.remote_path = remote_transform_3d.get_path_to(Globals.camera)
	#animation_player.play() ## Autoplays already

	## Start music
	if music:
		if Globals.music:
			Globals.music.start_track(music)

func _on_credits_finished() -> void:
	if return_scene:
		if return_scene.can_instantiate():
			get_tree().change_scene_to_packed(return_scene)
			return
			
	get_tree().quit()
