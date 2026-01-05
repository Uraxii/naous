class_name TutorialMusic
extends Node

const NOT_SO_STILL: DynamicMusicTrack = preload("uid://b4cwpyvpt3f8n")
const TRACK_2: DynamicMusicTrack = preload("uid://brq7gfor30m8x")
const AMBIVALENT_FELLOW: DynamicMusicTrack  = preload("uid://bay64fi84hggh")
const COMBAT: DynamicMusicTrack = preload("uid://dbkj5mkwehrw4")
const TRACK_5: DynamicMusicTrack = preload("uid://bcpglwarj06jc")
const FINALE: DynamicMusicTrack = preload("uid://bijg3owlp50gm")


func play_idle() -> void:
    Globals.music.start_track(NOT_SO_STILL)


func play_combat() -> void:
    Globals.music.start_track(COMBAT)


func play_background() -> void:
    Globals.music.start_track(AMBIVALENT_FELLOW)


func play_explore() -> void:
    Globals.music.start_track(TRACK_2)


func play_boss_combat() -> void:
    Globals.music.start_track(TRACK_5)
    

func play_finale() -> void:
    Globals.music.start_track(FINALE)


func _ready() -> void:
    DynamicMusicManager.set_music_bus_volume(0.2)
