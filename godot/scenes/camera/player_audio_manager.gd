class_name PlayerAudioManager
extends Node3D

const FOOTSTEP_1 = preload("uid://cxji5ers4057")
const FOOTSTEP_2 = preload("uid://822c5xfhc6mq")
@onready var footstep_timer: Timer = %FootstepTimer
@onready var player_footsteps_stream: AudioStreamPlayer3D = %PlayerFootstepsStream

const HIT_1 = preload("uid://dh840qk20p4lr")
@onready var player_attack_stream: AudioStreamPlayer3D = %PlayerAttackStream

const HIT_3 = preload("uid://bvefmn4ujv5i0")
@onready var player_damaged_stream: AudioStreamPlayer3D = %PlayerDamagedStream

var current_move_c: ComponentMove
var current_health_c: ComponentStat
var current_body: CharacterBody3D

var current_footstep := 0
func play_footsteps(play: bool) -> void:
    if !play:
        player_footsteps_stream.stop()
        footstep_timer.stop()
    else:
        footstep_timer.start()
        current_footstep = 1
        player_footsteps_stream.stream = FOOTSTEP_1
        player_footsteps_stream.play()


func play_attack(audio_stream: AudioStream) -> void:
    player_attack_stream.play()


func play_damaged() -> void:
    player_damaged_stream.play()


func _ready() -> void:
    Globals.signal_bus.play_player_attack.connect(play_attack)
    Globals.signal_bus.play_player_damaged.connect(play_damaged)
    Globals.signal_bus.control_entity.connect(_on_control_entity.call_deferred)
    
    footstep_timer.timeout.connect(_on_footstep_timer_timeout)


func _on_player_health_changed(new_value: float, old_value: float) -> void:
    if new_value < old_value:
        play_damaged()

func _on_player_moving(velocity: Vector3) -> void:
    if current_body.is_on_floor():
        if not velocity.is_zero_approx():
            if player_footsteps_stream.has_stream_playback():
                if not player_footsteps_stream.get_stream_playback().is_playing():
                    play_footsteps(true)
            else:
                # This happens if the footsteps haven't started yet
                play_footsteps(true)
        elif velocity.is_zero_approx():
            if player_footsteps_stream.has_stream_playback() and player_footsteps_stream.get_stream_playback().is_playing():
                play_footsteps(false)
    else:
        play_footsteps(false)


func _on_footstep_timer_timeout() -> void:
    if current_footstep == 0:
        player_footsteps_stream.stream = FOOTSTEP_1
        player_footsteps_stream.play()
        current_footstep = 1
    else:
        player_footsteps_stream.stream = FOOTSTEP_2
        player_footsteps_stream.play()
        current_footstep = 0


func _on_control_entity(entity: Entity) -> void:
    if entity is Player:
        if is_instance_valid(current_move_c):
            current_move_c.moving.disconnect(_on_player_moving)
        
        current_body = entity.body
        
        if is_instance_valid(current_health_c):
            current_health_c.change.disconnect(_on_player_health_changed)
        
        if is_instance_valid(current_health_c) and not current_health_c.change.is_connected(_on_player_health_changed):
            current_health_c.change.connect(_on_player_health_changed)
        
        current_move_c = entity.move
        
        # Having some weird issues with handling the footsteps, skipping for now
        #if is_instance_valid(current_move_c) and not current_move_c.moving.is_connected(_on_player_moving):
            #current_move_c.moving.connect(_on_player_moving)
