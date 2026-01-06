extends Node3D

@export var music: DynamicMusicTrack

@export var cancel_button_presses_to_quit:int = 3

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
const DEBOUNCE_TIME:float = 0.1
func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if not debouncing:
			debouncing = true
			var debounce:Tween = create_tween()
			debounce.tween_interval(DEBOUNCE_TIME)
			debounce.tween_callback(_undebounce)
			
			cancel_button_pressed_count += 1
			print("Cancel count %d" % [cancel_button_pressed_count])
			if cancel_button_pressed_count > cancel_button_presses_to_quit:
				cancel_credits()
				
func cancel_credits() -> void:
	const FADE_TIME:float = 3.0
	var fade:Tween = create_tween()
	fade.set_parallel()
	fade.tween_property(credits.get_child(0), ^"modulate", Color.TRANSPARENT, FADE_TIME)
	fade.tween_method(
		DynamicMusicManager.set_music_bus_volume, 
		DynamicMusicManager.get_music_bus_volume_linear(),
		0.0,
		FADE_TIME
		)
	fade.chain().tween_callback(_on_credits_finished)

func _on_credits_finished() -> void:
	## TODO go back to main menu??
	#queue_free()
	get_tree().quit()
