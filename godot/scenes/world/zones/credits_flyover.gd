extends Node3D

const RETURN_SCENE: String = "uid://cshn7uv20j780"

@export var music: DynamicMusicTrack
@export var cancel_button_presses_to_quit:int = 5

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
			
var cancel_button_pressed_count:int = 0
var debouncing:bool = false
func _undebounce() -> void: debouncing = false
const DEBOUNCE_TIME:float = 0.25

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if not debouncing:
			debouncing = true
			var debounce:Tween = create_tween()
			debounce.tween_interval(DEBOUNCE_TIME)
			debounce.tween_callback(_undebounce)
			
			cancel_button_pressed_count += 1
			print("Cancel count %d" % [cancel_button_pressed_count])
			credits.throb_cancel_label(cancel_button_presses_to_quit + 1 - cancel_button_pressed_count)
			if cancel_button_pressed_count > cancel_button_presses_to_quit:
				credits.cancel_revealing()

func _on_credits_finished() -> void:
	if RETURN_SCENE:
		get_tree().change_scene_to_file(RETURN_SCENE)
		return
			
	get_tree().quit()
