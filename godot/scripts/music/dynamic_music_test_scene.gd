extends Control

var selected_track_index:int = 0:
	set(value):
		if Music.tracks.size() > 0:
			selected_track_index = wrapi(value, 0, Music.tracks.size())
			selected_track_label.text = Music.tracks[selected_track_index].title
		else:
			selected_track_index = -1
			selected_track_label.text = "No tracks!"

@onready var selected_track_label: Label = %SelectedTrack
@onready var controller_sync_layers: PanelContainer = %ControllerSyncLayers # parent of vbox for layers
@onready var tracks_playing: VBoxContainer = %TracksPlaying

func _ready() -> void: selected_track_index = 0 # So the UI is populated.

func start_track(track:DynamicMusicTrack) -> void:
	var _player = Music.start_track(track)
	
func stop_track(track:DynamicMusicTrack) -> void:
	var player = Music.stop_track(track)
	if track.file is AudioStreamSynchronized:
		_populate_synchronized_layers(player.stream)
	
func _clear_synchronized_layers() -> void:
	var vbox:VBoxContainer = controller_sync_layers.get_child(0)
	for child in vbox.get_children():
		if child is CheckButton:
			child.free()
		
func _populate_synchronized_layers(stream:AudioStreamSynchronized) -> void:
	## Generate UI for interacting with our AudioStreamSynchronized
	var vbox:VBoxContainer = controller_sync_layers.get_child(0)
	for i in stream.stream_count:
		## Check button on/off
		var layer:AudioStream = stream.get_sync_stream(i)
		# Make a toggle
		var check_button := CheckButton.new()
		
		check_button.text = layer.resource_path.get_file() # This is just for UI purposes.
		check_button.button_pressed = true if stream.get_sync_stream_volume(i) > linear_to_db(0.1) else false
		
		check_button.toggled.connect(_on_sync_check_button_toggled.bind(stream, i))
		vbox.add_child(check_button)
		
		## Volume slider
		var slider:HSlider = HSlider.new()
		
		slider.step = 0.01 # 1%
		slider.tick_count = 5
		slider.ticks_position = Slider.TICK_POSITION_CENTER
		slider.ticks_on_borders = true
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.value = db_to_linear(stream.get_sync_stream_volume(i))
		
		slider.value_changed.connect(_on_sync_layer_slider_changed.bind(stream, i))
		vbox.add_child(slider)

func _repopulate_tracks_playing() -> void:
	for child in tracks_playing.get_children():
		child.free()
	var list:Array = []
	list.append_array(Music.positional_root.get_children())
	list.append_array(Music.non_positional_root.get_children())
	for item in list:
		if item is AudioStreamPlayer:
			var label:Label = Label.new()
			label.text = item.stream.resource_path.get_file()
			label.text += " - %s" % ["playing" if item.playing else "stopped"]
			tracks_playing.add_child(label)
			
			# Playback position slider
			var slider := AudioPlaybackPositionHSlider.new()
			slider.audio_player = item
			tracks_playing.add_child(slider)
			
func _process(delta: float) -> void:
	for child in tracks_playing.get_children():
		if child is HSlider:
			pass
	
func _on_sync_check_button_toggled(is_pressed:bool, stream:AudioStreamSynchronized, id:int) -> void:
	stream.set_sync_stream_volume(id, linear_to_db(1.0 if is_pressed else 0.0))
	
func _on_sync_layer_slider_changed(value:float, stream:AudioStreamSynchronized, id:int) -> void:
	stream.set_sync_stream_volume(id, linear_to_db(value))
	
func _on_playback_slider_changed(value:float, player:AudioStreamPlayer) -> void:
	player.seek(value)
	
func _on_start_playback_pressed() -> void:
	start_track(Music.tracks[selected_track_index])
	_repopulate_tracks_playing()
		
func _on_stop_playback_pressed() -> void:
	stop_track(Music.tracks[selected_track_index])
	_repopulate_tracks_playing()

func _on_track_select_prev_pressed() -> void:
	selected_track_index -= 1

func _on_track_select_next_pressed() -> void:
	selected_track_index += 1
