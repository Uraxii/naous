class_name TutorialMusic
extends Node

#const INITIAL_VOLUME: float = 0.2

const NOT_SO_STILL: DynamicMusicTrack = preload("uid://e26byi4f045n")
const INTO_OASIS: DynamicMusicTrack = preload("uid://brq7gfor30m8x")
const AMBIVALENT_FELLOW: DynamicMusicTrack  = preload("uid://bay64fi84hggh")
const ADVERSE_ENTITY: DynamicMusicTrack = preload("uid://dbkj5mkwehrw4")
const COALESCENT_DISCOVERIES: DynamicMusicTrack = preload("uid://bcpglwarj06jc")
const ECHOES_FINALE: DynamicMusicTrack = preload("uid://bijg3owlp50gm")

func play_idle() -> void:
    Globals.music.start_track(NOT_SO_STILL)


func play_combat() -> void:
    Globals.music.start_track(ADVERSE_ENTITY, true)
    ADVERSE_ENTITY.set_intensity(100)


func play_background() -> void:
    Globals.music.start_track(AMBIVALENT_FELLOW, true)


func play_explore() -> void:
    Globals.music.start_track(COALESCENT_DISCOVERIES, true)


func play_boss_combat() -> void:
    Globals.music.start_track(ADVERSE_ENTITY, true)
    ADVERSE_ENTITY.set_intensity(100)
    

func play_finale() -> void:
    Globals.music.start_track(INTO_OASIS)

func reduce_intensity_and_queue(track: DynamicMusicTrack, callback:Callable) -> void:
    if track.use_intensity:
        track.set_intensity(30)
        await get_tree().create_timer(4.0).timeout
    callback.call()
