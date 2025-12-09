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

@export_group("Intensities")
@export var use_intensity: bool = false
@export var intensity:int = 100:
	set(value):
		intensity = clampi(value, 0, 100)
		#prnt("Intensity changed to %d" % [intensity])
# more foo

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

func set_intensity(value:int) -> void:
	self.intensity = value

func do_intensity_process(stream: AudioStream) -> void:
	if not use_intensity: return
	
	if stream is AudioStreamSynchronized:
		# Simple implementation
		# Based on how many layers we have
		for i in stream.stream_count:
			#var layer:AudioStream = stream.get_sync_stream(i)
			if hundred_to_linear(intensity) > float(i+1) / float(stream.stream_count):
				# Playing
				stream.set_sync_stream_volume(i, linear_to_db(1.0))
			else:
				stream.set_sync_stream_volume(i, linear_to_db(0.0))

func hundred_to_linear(integer: int) -> float:
	return integer / 100.0
