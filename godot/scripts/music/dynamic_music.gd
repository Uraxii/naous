class_name DynamicMusicManager extends Node

## This class manages playing back music and triggering various scripted effects.
## NOTICE It is implemented as a Scene Autoload, so be sure to check
## "res://scenes/dynamic_music.tscn"
## You can see examples of implementation in
## "res://scenes/dynamic_music_testbench.tscn"


## Most methods  [DynamicMusicTrack], a unique [AudioStreamPlayer] node is created 
## Audio players are created and destroyed(? TODO) automatically when needed,

const BUS_NAME:StringName = &"Music"
## CRITICAL This is their position in the mixer effect stack. Ensure the tracks are in this order.
enum FX {
	Attenuation = 0,
	BandPass = 1,
	HighShelf = 2,
	LowShelf = 3,
}
class FXBaselines:
	const Attenuation:float = 0.0 ## dB gain
	const HighShelf:float = 1.0 ## Linear gain
	const LowShelf:float = 1.0 ## Linear gain
	const BandPass:float = 0.0 ## Linear resonance

@export_group("Components")
@export var non_positional_root: Node
@export var positional_root: Node3D
@export var proto_non_positional_player:AudioStreamPlayer
@export var proto_positional_player:AudioStreamPlayer3D

@export var tracks:Array[DynamicMusicTrack]

@export_group("Behavior")
const force_single_track_playback: bool = true ## CRITICAL Do not change. Simplifies handling song changes, disable for more control
const clear_player_when_stopped: bool = true ## HACK having issues with volume when returning to already played tracks.
@export var continuous_playback: bool = false:
	set(value):
		print("DynamicMusicManager: continuous_playback now %s" % value)
		continuous_playback = value
@export_range(0.1, 10.0, 0.1, "or_greater", "hide_slider") var minimum_transition_time:float = 0.1
@export_range(0.1, 30.0, 0.1, "or_greater", "hide_slider") var default_transition_time:float = 5.0

## Cached integer for the index of the Music bus in [AudioServer].
var music_bus_idx:int:
	get:
		if not music_bus_idx:
			music_bus_idx = get_bus_idx()
		return music_bus_idx
		

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

var attenuation_baseline:float = 0.0 ## db gain.
var highs_baseline:float = 1.0 ## Linear gain.
var lows_baseline:float = 1.0 ## Linear gain.
var band_pass_baseline:float = 0.0 ## Linear resonance.

var attenuation_reset_timer: Tween
var highs_reset_timer: Tween
var lows_reset_timer: Tween
var band_pass_reset_timer: Tween


#region Virtuals
func _ready() -> void:
	assert(get_bus_idx() != -1, 'Missing a "%s" bus in the current audio mixer bus!' % [BUS_NAME])

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		pass
	
	## Intensity reactivity implementation.
	## Since tracks are just resources, we're firing our own process.
	## TODO Maybe instead we could make a custom AudioStreamPlayer that
	## fires this process.
	for track in tracks:
		if track.is_playing && track.use_intensity:
			# Per layer adjustments (intensity)
			var player = get_player(track)
			if player:
				track.do_intensity_process(player.stream)
#endregion

#region Tweens
## Provided a reference [param tween], will [method Tween.kill], and always
## returns a new [Tween] binded to [param attach] using [method Node.create_tween].
static func kill_create(tween, attach:Node) -> Tween:
	if tween:
		if tween is Tween:
			tween.kill()
	return attach.create_tween()
	
static func check_kill(tween) -> void:
	if tween is Tween:
		tween.kill()
#endregion

#region Mixer Bus - Utilities
static func set_music_bus_volume(volume_linear:float) -> void:
	AudioServer.set_bus_volume_linear(get_bus_idx(), volume_linear)
	
static func set_music_bus_volume_db(volume_db:float) -> void:
	AudioServer.set_bus_volume_db(get_bus_idx(), volume_db)
	
static func get_music_bus_volume_linear() -> float:
	return AudioServer.get_bus_volume_linear(get_bus_idx())
	
static func get_music_bus_volume_db() -> float:
	return AudioServer.get_bus_volume_db(get_bus_idx())

static func get_bus_idx() -> int:
	return AudioServer.get_bus_index(BUS_NAME)
	
## Use [member FX] for [param index].
static func get_fx(fx_index:FX) -> AudioEffect:
	return AudioServer.get_bus_effect(get_bus_idx(), fx_index)
	
static func get_band_pass() -> AudioEffectBandPassFilter:
	return get_fx(FX.BandPass)
	
static func get_attenuation() -> AudioEffectAmplify:
	return get_fx(FX.Attenuation)

static func get_highs_filter() -> AudioEffectHighShelfFilter:
	return get_fx(FX.HighShelf)
	
static func get_lows_filter() -> AudioEffectLowShelfFilter:
	return get_fx(FX.LowShelf)

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

## The local baseline variable can be adjusted by gameplay. This method can be used
## to ensure that after a scene change, these values are properly defaulted.
## Each of these values within [class FXBaselines] represents a neutral state.
func reset_all_fx_baselines_to_default() -> void:
	attenuation_baseline = FXBaselines.Attenuation
	highs_baseline = FXBaselines.HighShelf
	lows_baseline = FXBaselines.LowShelf
	band_pass_baseline = FXBaselines.BandPass

## Transitions each of the filters back to their respective current baseline values.
## Primarily used by [DynamicMusicEvent] to reset their active effect.
func reset_all_fx_to_baselines(transition:float = default_transition_time) -> void:
	for type in FX: reset_fx(type, transition)

func reset_fx(fx:FX, transition:float = default_transition_time) ->  void:
	match fx:
		FX.Attenuation:
			attenuate(attenuation_baseline, transition)
		FX.HighShelf:
			high_shelf(get_highs_filter().cutoff_hz, highs_baseline, transition)
		FX.LowShelf:
			low_shelf(get_lows_filter().cutoff_hz, lows_baseline, transition)
		FX.BandPass:
			band_pass(get_band_pass().cutoff_hz, band_pass_baseline, transition)
			
func timed_reset(fx:FX, delay:float, transition:float = default_transition_time) -> void:
	var timer: Tween
	
	match fx:
		FX.Attenuation:
			timer = attenuation_reset_timer
		FX.HighShelf:
			timer = highs_reset_timer
		FX.LowShelf:
			timer = lows_reset_timer
		FX.BandPass:
			timer = band_pass_reset_timer
			
	timer = kill_create(timer, self)
	timer.tween_interval(delay)
	timer.tween_callback(
		reset_fx.bind(fx, transition)
	)

## Adjust the [AudioEffectBandPassFilter] on the Music bus (see [AudioServer]).
## [param frequency] is in hz,
## [param resonance] is 0.0 to 1.0, where zero is no effect.
## [param transition] is in seconds. The minimum is 0.1s for sanity's sake.
## There is a configurable global minimum, see [member minimum_transition_time].
func band_pass(frequency:float, resonance:float, transition:float = 0.0) -> void:
	band_pass_tween = kill_create(band_pass_tween, self)
	check_kill(band_pass_reset_timer)
	
	if transition >= 0.1:
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
	attenuation_tween = kill_create(attenuation_tween, self)
	check_kill(attenuation_reset_timer)
	
	if transition >= 0.1:
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
	highs_tween = kill_create(highs_tween, self)
	check_kill(highs_reset_timer)
	
	if transition >= 0.1:
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
	lows_tween = kill_create(lows_tween, self)
	check_kill(lows_reset_timer)
	
	if transition >= 0.1:
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
	var new_player
	if track.treat_positional:
		## DEPRECATED
		for player:AudioStreamPlayer3D in positional_root.get_children():
			if player.stream == track.file:
				return player
				
		## New 3D Player
		#var new_player:AudioStreamPlayer3D
		new_player = proto_positional_player.duplicate() as AudioStreamPlayer3D
		
		new_player.stream = track.file
		new_player.bus = BUS_NAME
		
		new_player.name = track.title
		positional_root.add_child(new_player)
		
	else:
		
		for player:AudioStreamPlayer in non_positional_root.get_children():
			if player.stream == track.file:
				return player
				
		## New Static Player
		#var new_player:AudioStreamPlayer
		new_player = proto_non_positional_player.duplicate() as AudioStreamPlayer
		
		new_player.stream = track.file
		new_player.bus = BUS_NAME
		
		new_player.name = track.title
		non_positional_root.add_child(new_player)
	
	## HACK
	#if clear_player_when_stopped:
		#new_player.finished.connect(
			#func():
				#new_player.call_deferred(&"queue_free")
				#print("Freeing player %s" % new_player.name)
		#)
			
	return new_player
		
func get_audio_players() -> Array[AudioStreamPlayer]:
	var array:Array = []
	array.append_array(non_positional_root.get_children())
	array.append_array(positional_root.get_children())
	return array
	
## This method uses a hard stop, skipping any transitions. Use for utility.
func stop_all_players(and_free_instances:bool = false) -> void:
	for player in get_audio_players():
		player.stop()
		
	if and_free_instances:
		clear_all_stopped_tracks()
		
func stop_all_tracks() -> void:
	#var awaiting: Array[DynamicMusicTrack] = [] ## TODO might be useful
	for track in tracks:
		#if track.is_playing:
			#awaiting.append(track)
		track.stop()
	
func clear_all_stopped_tracks() -> void:
	for player:AudioStreamPlayer in get_audio_players():
		if not player.has_stream_playback():
			player.queue_free()

## You can call this 
func start_track(track:DynamicMusicTrack, force_looping:bool = false) -> AudioStreamPlayer:
	if force_single_track_playback:
		for _track in tracks:
			if _track.is_playing:
				stop_track(_track)
				if _track.is_playing:
					await _track.playback_changed
					## Note this will need refactor to work outside of `force_single_track_playback`
	
	track.is_playing = true
	var player = get_player(track)
	player.play()
	
	var track_transition: Curve = track.trans_start_fade_in
	if track_transition:
		player.volume_linear = track_transition.sample_baked(track_transition.min_domain)
		var trans_tween:Tween = player.create_tween()
		trans_tween.tween_method(
			DynamicMusicTrack.set_volume_from_curve.bind(
				player,
				track_transition
				),
			#player.volume_linear,
			track_transition.min_domain,
			track_transition.max_domain,
			track_transition.max_domain
			)
	else:
		player.volume_linear = 1.0 ## Reset the volume
		
	if not player.finished.is_connected(_on_track_finished):
		player.finished.connect(_on_track_finished.bind(track, force_looping))
	
	return player
	
func stop_track(track:DynamicMusicTrack) -> AudioStreamPlayer:
	var player = get_player(track)
	
	if player.playing:
		
		var track_transition: Curve = track.trans_stop_fade_out
		if track_transition:
			player.volume_linear = track_transition.sample_baked(track_transition.min_domain)
			var trans_tween:Tween = player.create_tween()
			trans_tween.tween_method(
				DynamicMusicTrack.set_volume_from_curve.bind(
					player,
					track_transition
					),
				#player.volume_linear,
				track_transition.min_domain,
				track_transition.max_domain,
				track_transition.max_domain
				)
			trans_tween.tween_callback(player.stop)
			trans_tween.tween_callback(track.set.bind(&"is_playing", false))
		else:
			player.stop()
			track.is_playing = false
			
	elif track.is_playing:
		track.is_playing = false
		
	return player

func _on_track_finished(track: DynamicMusicTrack, loop:bool = false) -> void:
	if loop:
		# Start the track again
		Globals.music.start_track(track)
	else:
	
		track.is_playing = false
		
		if continuous_playback:
			## get the next track
			var next_track: DynamicMusicTrack = null
			var t_index: int = tracks.find(track)
			var iterations: int = 0
			while next_track == null:
				
				## Prevent infinite loop
				iterations += 1
				if iterations > tracks.size() * 2:
					return
				
				if t_index < 0:
					t_index = 0
				else:
					t_index += 1
					
				var _track = tracks.get(t_index)
				if _track != null:
					if _track.include_in_continuous_playlist:
						next_track = _track
					else:
						continue
				else:
					## Out of bounds
					t_index = -1
					continue
			
			Globals.music.start_track(next_track)
