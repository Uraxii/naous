class_name TutorialMusic
extends Node

const INITIAL_VOLUME: float = 0.2

const NOT_SO_STILL: DynamicMusicTrack = preload("uid://e26byi4f045n")
const INTO_OASIS: DynamicMusicTrack = preload("uid://brq7gfor30m8x")
const AMBIVALENT_FELLOW: DynamicMusicTrack  = preload("uid://bay64fi84hggh")
const ADVERSE_ENTITY: DynamicMusicTrack = preload("uid://dbkj5mkwehrw4")
const COALESCENT_DISCOVERIES: DynamicMusicTrack = preload("uid://bcpglwarj06jc")
const ECHOES_FINALE: DynamicMusicTrack = preload("uid://bijg3owlp50gm")

func _ready() -> void:
    DynamicMusicManager.set_music_bus_volume(INITIAL_VOLUME)

func play_idle() -> void:
    Globals.music.start_track(NOT_SO_STILL)


func play_combat() -> void:
    Globals.music.start_track(ADVERSE_ENTITY)


func play_background() -> void:
    Globals.music.start_track(AMBIVALENT_FELLOW)


func play_explore() -> void:
    Globals.music.start_track(INTO_OASIS)


func play_boss_combat() -> void:
    Globals.music.start_track(COALESCENT_DISCOVERIES)
    

func play_finale() -> void:
    Globals.music.start_track(ECHOES_FINALE)
