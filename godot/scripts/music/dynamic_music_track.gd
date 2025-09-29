class_name DynamicMusicTrack extends Resource

## Audio resource.
@export var file:AudioStream

## Title of the song.
@export_placeholder("Song Title") var title:String:
	get:
		if not title:
			return "EMPTY TITLE PROPERTY"
		else:
			return title

## Tempo; Beats per minute.
@export var bpm:int

## Time signature.
@export var time_signature:Vector2i = Vector2i(4,4)

## Name, Beat Count.
@export var markers:Dictionary[StringName, int] = {"start": 0}

@export_group("Treatment", "treat_")
@export var treat_positional:bool = false

@export_group("Transitions", "trans_")
@export var trans_start_fade_in: Curve ## X is in seconds, Y is volume.
@export var trans_end_fade_out: Curve ## X is in seconds, Y is volume.
@export var trans_seek_crossfade_in: Curve ## X is in seconds, Y is volume.
@export var trans_seek_crossfade_out: Curve ## X is in seconds, Y is volume.

var is_playing:bool = false

func _init() -> void: prnt("Loaded %s." % [title])

func set_bpm_from_track() -> void:
	var _bpm:float = file._get_bpm()
	if _bpm != null:
		if _bpm > 0.0:
			bpm = int(_bpm)
			return
	push_error("Track doesn't have BPM set. Check import settings.")

func prnt(x) -> void:
	## Print log. Swap me out some day.
	print_debug(x)

static func set_volume_from_curve(curve_point: float, player:AudioStreamPlayer, curve: Curve) -> void:
	player.volume_linear = curve.sample_baked(curve_point)
