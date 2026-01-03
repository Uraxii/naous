class_name DynamicMusicEvent extends Resource

## TESTING -- this class is Experimental.
## The idea was to make a resource that can be "fired" as an event in the
## dynamic music system. This would be used in scripts to react to gameplay
## and apply some desired effect to the music.

signal activated
signal deactivated

enum MODES {
	DURATION = 0,
	ONESHOT = 1,
	TOGGLE = 2,
}

@export var mode:MODES = MODES.DURATION

@export_group("Duck Volume", "duck_")
@export var duck_enabled:bool = false
@export_range(-60, 0, 1.5) var duck_volume:float = 0.0
@export var duck_transitions: DynamicMusicEventTransitionsConfig

@export_group("High Shelf", "hs_")
@export var hs_enabled:bool = false
@export_range(100, 12000, 50) var hs_frequency:float = 1000.0
@export_range(-60, 0, 1.5) var hs_gain:float = 0.0
@export var hs_transitions: DynamicMusicEventTransitionsConfig

@export_group("Low Shelf", "ls_")
@export var ls_enabled:bool = false
@export_range(100, 12000, 50) var ls_frequency:float = 1000.0
@export_range(-60, 0, 1.5) var ls_gain:float = 0.0
@export var ls_transitions: DynamicMusicEventTransitionsConfig

@export_group("Band Pass", "bp_")
@export var bp_enabled:bool = false
@export_range(100, 12000, 25) var bp_frequency:float = 1200.0
@export_range(0.0, 1.0, 0.05) var bp_resonance:float = 0.0
@export var bp_transitions: DynamicMusicEventTransitionsConfig


func activate() -> void:
	if duck_enabled: Music.attenuate(duck_volume, duck_transitions.transition_in)
	if hs_enabled: Music.high_shelf(hs_frequency, hs_gain, hs_transitions.transition_in)
	if ls_enabled: Music.low_shelf(ls_frequency, ls_gain, ls_transitions.transition_in)
	if bp_enabled: Music.band_pass(bp_frequency, bp_resonance, bp_transitions.transition_in)
	
	if mode == MODES.DURATION:
		if duck_enabled: Music.timed_reset(
			DynamicMusicManager.FX.Attenuation,
			duck_transitions.duration,
			duck_transitions.transition_out
			)
		if hs_enabled: Music.timed_reset(
			DynamicMusicManager.FX.HighShelf,
			hs_transitions.duration,
			hs_transitions.transition_out
			)
		if ls_enabled: Music.timed_reset(
			DynamicMusicManager.FX.LowShelf,
			ls_transitions.duration,
			ls_transitions.transition_out
			)
		if bp_enabled: Music.timed_reset(
			DynamicMusicManager.FX.BandPass,
			bp_transitions.duration,
			bp_transitions.transition_out
			)
	activated.emit()

func deactivate() -> void:
	if duck_enabled: Music.reset_fx(
		DynamicMusicManager.FX.Attenuation,
		duck_transitions.transition_out
		)
	if hs_enabled: Music.reset_fx(
		DynamicMusicManager.FX.HighShelf,
		hs_transitions.transition_out
		)
	if ls_enabled: Music.reset_fx(
		DynamicMusicManager.FX.LowShelf,
		ls_transitions.transition_out
		)
	if bp_enabled: Music.reset_fx(
		DynamicMusicManager.FX.BandPass,
		bp_transitions.transition_out
		)
	
	deactivated.emit()
