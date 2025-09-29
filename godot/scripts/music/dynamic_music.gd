@tool class_name DynamicMusicManager extends Node

const MUSIC_BUS_NAME:StringName = &"Music"
enum FX {
	Attenuation = 0,
	BandPass = 1,
	HighShelf = 2,
	LowShelf = 3,
}

@export var non_positional_root: Node
@export var positional_root: Node3D

@export var tracks:Array[DynamicMusicTrack]

@export_group("Prototypes", "proto_")
@export var proto_non_positional_player:AudioStreamPlayer
@export var proto_positional_player:AudioStreamPlayer3D

@export_group("Behavior")
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_slider") var minimum_transition_time:float = 0.1

## Cached integer for the index of the Music bus in [AudioServer].
var music_bus:int:
	get:
		if not music_bus:
			music_bus = get_music_bus_idx()
		return music_bus
		

## This effect is used for ducking the Volume of the whole music bus, for dynamic gameplay purposes.
## It exists because the Player's options allow them to change the overall
## volume of Music, which we assign to the bus volume fader.
var attenuation_filter: AudioEffectAmplify:
	get:
		if not attenuation_filter:
			attenuation_filter = get_attenuation()
		return attenuation_filter
		
var highs_filter: AudioEffectHighShelfFilter:
	get:
		if not highs_filter:
			highs_filter = get_highs_filter()
		return highs_filter
		
var lows_filter: AudioEffectLowShelfFilter:
	get:
		if not lows_filter:
			lows_filter = get_lows_filter()
		return lows_filter
		
## Cached resource.
var band_pass_filter: AudioEffectBandPassFilter:
	get:
		if not band_pass_filter:
			band_pass_filter = get_band_pass()
		return band_pass_filter
		
var attenuation_tween:Tween
var highs_tween:Tween
var lows_tween:Tween
var band_pass_tween:Tween


#region Virtuals
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		pass
	pass
#endregion

#region Tweens
## Provided a reference [param tween], will [method Tween.kill], and always
## returns a new [Tween] binded to [param attach] using [method Node.create_tween].
static func check_kill(tween, attach:Node) -> Tween:
	if tween:
		if tween is Tween:
			tween.kill()
	return attach.create_tween()
	
#endregion

#region Mixer Bus - Utilities
static func set_music_bus_volume(volume_linear:float) -> void:
	AudioServer.set_bus_volume_linear(get_music_bus_idx(), volume_linear)
	
static func get_music_bus_volume_linear() -> float:
	return AudioServer.get_bus_volume_linear(get_music_bus_idx())
	
static func get_music_bus_volume_db() -> float:
	return AudioServer.get_bus_volume_db(get_music_bus_idx())

static func get_music_bus_idx() -> int:
	return AudioServer.get_bus_index(MUSIC_BUS_NAME)
	
## Use [member FX] for [param index].
static func get_fx(bus_index:int, fx_index:FX) -> AudioEffect:
	return AudioServer.get_bus_effect(bus_index, fx_index)
	
static func get_band_pass() -> AudioEffectBandPassFilter:
	return get_fx(get_music_bus_idx(), FX.BandPass)
	
static func get_attenuation() -> AudioEffectAmplify:
	return get_fx(get_music_bus_idx(), FX.Attenuation)

static func get_highs_filter() -> AudioEffectHighShelfFilter:
	return get_fx(get_music_bus_idx(), FX.HighShelf)
	
static func get_lows_filter() -> AudioEffectLowShelfFilter:
	return get_fx(get_music_bus_idx(), FX.LowShelf)


static func set_filter_resonance(value:float, fx: AudioEffectFilter) -> void:
	#fx comes after value in the args because of how Callable.bind() works.
	fx.resonance = value
	
static func set_filter_cutoff(hz:float, fx: AudioEffectFilter) -> void:
	#fx comes after value in the args because of how Callable.bind() works.
	fx.cutoff_hz = hz
	
static func set_filter_slope(slope:AudioEffectFilter.FilterDB, fx: AudioEffectFilter) -> void:
	fx.db = slope
	
static func set_filter_gain_db(volume_db:float, fx: AudioEffectFilter) -> void:
	#fx comes after value in the args because of how Callable.bind() works.
	fx.gain = db_to_linear(volume_db)

## Adjust the [AudioEffectBandPassFilter] on the Music bus (see [AudioServer]).
## [param frequency] is in hz,
## [param resonance] is 0.0 to 0.1, where zero is no effect.
## [param transition] is in seconds. The minimum is 0.1s for sanity's sake.
## There is a configurable global minimum, see [member minimum_transition_time].
func band_pass(frequency:float, resonance:float, transition:float = 0.0) -> void:
	band_pass_tween = check_kill(band_pass_tween, self)
	#var band_pass_filter:AudioEffectBandPassFilter = get_band_pass() # Singleton cached.
	
	if transition > 0.1:
		transition = maxf(transition, minimum_transition_time)
		band_pass_tween.set_ease(Tween.EASE_OUT)
		band_pass_tween.tween_method(
			set_filter_resonance.bind(band_pass_filter),
			band_pass_filter.resonance,
			resonance,
			transition
		)
		band_pass_tween.tween_method(
			set_filter_cutoff.bind(band_pass_filter),
			band_pass_filter.cutoff_hz,
			frequency,
			transition
		)
		
	else:
		set_filter_cutoff(frequency, band_pass_filter)
		set_filter_resonance(resonance, band_pass_filter)
		
## Adjust the [AudioEffectAmplify] on the Music bus (see [AudioServer]).
## [param gain_db] is in decibels, where 0.0 is full volume and -6.0 is half perceived volume.
## [param transition] is in seconds. The minimum is 0.1s for sanity's sake.
## There is a configurable global minimum, see [member minimum_transition_time].
func attenuate(gain_db:float, transition:float = 0.0) -> void:
	attenuation_tween = check_kill(attenuation_tween, self)
	
	if transition > 0.1:
		transition = maxf(transition, minimum_transition_time)
		#attenuation_tween.set_ease(Tween.EASE_IN_OUT) # Linear is probably best.
		attenuation_tween.tween_property(
			attenuation_filter,
			^"volume_db",
			gain_db,
			transition
		)
		
	else:
		attenuation_filter.volume_db = gain_db
		
## Adjust the [AudioEffectHighShelfFilter] on the Music bus (see [AudioServer]).
## [param frequency] is in hz,
## [param gain] is in decibels, where 0.0 is full volume.
## [param transition] is in seconds. The minimum is 0.1s for sanity's sake.
## There is a configurable global minimum, see [member minimum_transition_time].
func high_shelf(frequency:float, gain:float, transition:float = 0.0) -> void:
	highs_tween = check_kill(highs_tween, self)
	#var band_pass_filter:AudioEffectBandPassFilter = get_band_pass() # Singleton cached.
	
	if transition > 0.1:
		transition = maxf(transition, minimum_transition_time)
		highs_tween.set_ease(Tween.EASE_OUT)
		highs_tween.tween_method(
			set_filter_gain_db.bind(highs_filter),
			highs_filter.gain,
			gain,
			transition
		)
		highs_tween.tween_method(
			set_filter_cutoff.bind(highs_filter),
			highs_filter.cutoff_hz,
			frequency,
			transition
		)
		
	else:
		set_filter_cutoff(frequency, highs_filter)
		set_filter_gain_db(gain, highs_filter)
		
## Adjust the [AudioEffectLowShelfFilter] on the Music bus (see [AudioServer]).
## [param frequency] is in hz,
## [param gain] is in decibels, where 0.0 is full volume.
## [param transition] is in seconds. The minimum is 0.1s for sanity's sake.
## There is a configurable global minimum, see [member minimum_transition_time].
func low_shelf(frequency:float, gain:float, transition:float = 0.0) -> void:
	lows_tween = check_kill(lows_tween, self)
	#var band_pass_filter:AudioEffectBandPassFilter = get_band_pass() # Singleton cached.
	
	if transition > 0.1:
		transition = maxf(transition, minimum_transition_time)
		lows_tween.set_ease(Tween.EASE_IN)
		lows_tween.tween_method(
			set_filter_gain_db.bind(lows_filter),
			lows_filter.gain,
			gain,
			transition
		)
		lows_tween.tween_method(
			set_filter_cutoff.bind(lows_filter),
			lows_filter.cutoff_hz,
			frequency,
			transition
		)
		
	else:
		set_filter_cutoff(frequency, lows_filter)
		set_filter_gain_db(gain, lows_filter)

#endregion

#region Audio Players
func get_player(track:DynamicMusicTrack) -> Variant:
	if track.treat_positional:
		
		for player:AudioStreamPlayer3D in positional_root.get_children():
			if player.stream == track.file:
				return player
				
		## New 3D Player
		var new_player:AudioStreamPlayer3D
		new_player = proto_positional_player.duplicate()
		
		new_player.stream = track.file
		new_player.bus = MUSIC_BUS_NAME
		
		positional_root.add_child(new_player)
		
		return new_player
		
	else:
		
		for player:AudioStreamPlayer in non_positional_root.get_children():
			if player.stream == track.file:
				return player
				
		## New Static Player
		var new_player:AudioStreamPlayer
		new_player = proto_non_positional_player.duplicate()
		
		new_player.stream = track.file
		new_player.bus = MUSIC_BUS_NAME
		
		non_positional_root.add_child(new_player)
			
		return new_player
		
func get_audio_players() -> Array[AudioStreamPlayer]:
	var array:Array = []
	array.append_array(non_positional_root.get_children())
	array.append_array(positional_root.get_children())
	return array
	
func clear_all_stopped_tracks() -> void:
	for player:AudioStreamPlayer in get_audio_players():
		if not player.has_stream_playback():
			player.queue_free()

func start_track(track:DynamicMusicTrack) -> AudioStreamPlayer:
	var player = get_player(track)
	player.play()
		
	if track.trans_start_fade_in:
			pass
			
	return player
	
func stop_track(track:DynamicMusicTrack) -> AudioStreamPlayer:
	var player = get_player(track)
	player.stop()
		
	if track.trans_end_fade_out:
			player.volume_linear = track.trans_start_fade_in.sample_baked(track.trans_end_fade_out.min_domain)
			var trans_tween:Tween = player.create_tween()
			trans_tween.tween_method(
				DynamicMusicTrack.set_volume_from_curve.bind(
					player,
					track.trans_end_fade_out
					),
				player.volume_linear,
				track.trans_end_fade_out.max_domain,
				track.trans_end_fade_out.max_domain
				)
				
	return player
