class_name AudioPlaybackPositionHSlider extends HSlider

@export var audio_player:AudioStreamPlayer:
	set(value):
		audio_player = value
		configure()

func _process(delta: float) -> void:
	if audio_player:
		if audio_player.playing:
			set_value_no_signal(audio_player.get_playback_position())
		
func configure() -> void:
	if not audio_player is AudioStreamPlayer:
		return
	else:
		step = 1.0 # Seconds
		tick_count = int(audio_player.stream.get_length() / 15)
		ticks_position = Slider.TICK_POSITION_CENTER
		ticks_on_borders = true
		min_value = 0.0
		max_value = audio_player.stream.get_length()
		value = audio_player.get_playback_position()
		
		value_changed.connect(audio_player.seek)
