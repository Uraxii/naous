extends Node3D

const RETURN_SCENE: PackedScene = preload("uid://cshn7uv20j780")

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
	if RETURN_SCENE:
		if RETURN_SCENE.can_instantiate():
			get_tree().change_scene_to_packed(RETURN_SCENE)
			return
			
	get_tree().quit()
