class_name DynamicMusicReactToPlayerMovement extends Node

var affected_track: DynamicMusicTrack
const intensity_not_moving: int = 60
const intensity_moving: int = 100
const react_time: float = 3.0

var return_tween: Tween

func setup(player:Player, track: DynamicMusicTrack) -> void:
	var move_component:ComponentMove = player.components.find(ComponentMove.ID)
	move_component.moving.connect(_on_player_moving)
	
	affected_track = track

var debouncing:bool = false
const DEBOUNCE_TIME:float = 0.5
var debouncer:Tween = create_tween()
func debounce() -> void:
	debouncing = true
	debouncer = create_tween()
	debouncer.tween_interval(DEBOUNCE_TIME)
	debouncer.tween_callback(_undebounce)
func _undebounce() -> void: debouncing = false

var _stopped_moving_tween: Tween
func _on_player_moving(velocity: Vector3) -> void:
	if debouncing: return
	if not Globals.music: return
	if affected_track:
		if affected_track.is_playing:
			debounce()
			
			if velocity.is_zero_approx():
				affected_track.set_intensity(intensity_not_moving)
			else:
				affected_track.set_intensity(intensity_moving)
			
				if _stopped_moving_tween:
					if _stopped_moving_tween.is_running():
						_stopped_moving_tween.kill()
				_stopped_moving_tween = create_tween()
				_stopped_moving_tween.tween_interval(react_time)
				_stopped_moving_tween.tween_callback(_on_player_stopped_moving)
				
func _on_player_stopped_moving() -> void:
	if not Globals.music: return
	
	affected_track.set_intensity(intensity_not_moving)
