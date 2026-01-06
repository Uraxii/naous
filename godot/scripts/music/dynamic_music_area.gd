class_name DynamicMusicArea extends Area3D

## Play this track when the player is inside the area.
## Stop the track when they leave.

@export var track: DynamicMusicTrack
@export var disable_when_stopped: bool = false

func _ready() -> void:
    monitoring = true
    
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    
func start_playback() -> void:
    if track:
        if not track.is_playing:
            track.play()
    
func stop_playback() -> void:
    if track:
        if track.is_playing:
            track.stop()
        if disable_when_stopped:
            set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
            set_deferred("monitoring", false)

func _check_physics_body_is_local_player_instance(body: Node3D) -> bool:
    if body is ComponentCharacterBody:
        if body.entity:
            if body.entity is Player:
                if body.entity.is_client:
                    # It's the player
                    print_debug("DynamicMusicArea detected local Player: %s" % [track.title if track else "null"])
                    return true
    return false

func _on_body_entered(body: Node3D) -> void:
    if _check_physics_body_is_local_player_instance(body):
        start_playback()
    
func _on_body_exited(body: Node3D) -> void:
    if _check_physics_body_is_local_player_instance(body):
        stop_playback()
