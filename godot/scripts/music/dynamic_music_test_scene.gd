extends Control

## TESTING
## This script provides most of the functionality in the test bench scene for
## [DynamicGlobals.music].
## See "res://scenes/dynamic_Globals.music_testbench.tscn"

var selected_track_index:int = 0:
	set(value):
		if Globals.music.tracks.size() > 0:
			selected_track_index = wrapi(value, 0, Globals.music.tracks.size())
			_on_selected_track_changed()
		else:
			selected_track_index = -1
			selected_track_label.text = "No tracks!"

@onready var selected_track_label: Label = %SelectedTrack
@onready var controller_sync_layers: PanelContainer = %ControllerSyncLayers # parent of vbox for layers
@onready var tracks_playing: VBoxContainer = %TracksPlaying

@onready var intensity_h_slider: HSlider = %IntensityHSlider
@onready var intensity_slider_label: Label = %IntensitySliderLabel


func _ready() -> void:
	if not Globals.music:
		push_error("Couldn't find instance of DynamicMusicManager. Were Globals skipped?")
		push_warning("Forcing GlobalManager to instance DynamicMusicManager scene...")
		## HACK
		Globals.music = Globals.new_global_scene("Music", preload("uid://dgl2tc7u5oid2"))
	
	selected_track_index = 0 # So the UI is populated.
	update_intensity_slider()
	update_intensity_label()

func start_track(track:DynamicMusicTrack) -> void:
	var player = await Globals.music.start_track(track)
	
func stop_track(track:DynamicMusicTrack) -> void:
	var player = await Globals.music.stop_track(track)
	
func _clear_synchronized_layers() -> void:
	var vbox:VBoxContainer = controller_sync_layers.get_child(0)
	for child in vbox.get_children():
		if child.has_meta(&"template"):
			if child.get_meta(&"template", false):
				continue
		child.free()
		
func _populate_synchronized_layers(stream:AudioStreamSynchronized) -> void:
	## Generate UI for interacting with our AudioStreamSynchronized
	var vbox:VBoxContainer = controller_sync_layers.get_child(0)
	for i in stream.stream_count:
		var layer:AudioStream = stream.get_sync_stream(i)
		
		# Make a toggle check button on/off
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
		
		check_button.set_meta(&"layer_id", i)
		slider.set_meta(&"layer_id", i)
		
func _update_synchronized_layers() -> void:
	await get_tree().process_frame
	var stream = Globals.music.get_player(get_selected_track()).stream
	if stream is AudioStreamSynchronized:
		for child in controller_sync_layers.get_child(0).get_children():
			var layer_id = child.get_meta(&"layer_id", -1)
			if layer_id >= 0:
				if child is HSlider:
					child.value = db_to_linear(stream.get_sync_stream_volume(layer_id))
				elif child is CheckButton:
					child.button_pressed = true if stream.get_sync_stream_volume(layer_id) > linear_to_db(0.1) else false
					
				print_debug(layer_id, ": ", stream.get_sync_stream_volume(layer_id))

func _repopulate_tracks_playing() -> void:
	for child in tracks_playing.get_children():
		child.free()
	var list:Array = []
	list.append_array(Globals.music.positional_root.get_children())
	list.append_array(Globals.music.non_positional_root.get_children())
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
			
#func _process(delta: float) -> void:
	#for child in tracks_playing.get_children():
		#if child is HSlider:
			#pass
	
func _on_sync_check_button_toggled(is_pressed:bool, stream:AudioStreamSynchronized, id:int) -> void:
	stream.set_sync_stream_volume(id, linear_to_db(1.0 if is_pressed else 0.0))
	
func _on_sync_layer_slider_changed(value:float, stream:AudioStreamSynchronized, id:int) -> void:
	stream.set_sync_stream_volume(id, linear_to_db(value))
	
func _on_playback_slider_changed(value:float, player:AudioStreamPlayer) -> void:
	player.seek(value)
	
func get_selected_track() -> DynamicMusicTrack:
	return Globals.music.tracks[selected_track_index]
	
func _on_selected_track_changed() -> void:
	var track = get_selected_track()
	if track:
		selected_track_label.text = track.title
		
		var player = Globals.music.get_player(track)
		if player:
			update_intensity_slider()
			update_intensity_label()
			
			if track.file is AudioStreamSynchronized:
				_populate_synchronized_layers(player.stream)
			else:
				_clear_synchronized_layers()
	
func _on_start_playback_pressed() -> void:
	start_track(get_selected_track())
	_repopulate_tracks_playing()
		
func _on_stop_playback_pressed() -> void:
	stop_track(get_selected_track())
	_repopulate_tracks_playing()

func _on_track_select_prev_pressed() -> void:
	selected_track_index -= 1

func _on_track_select_next_pressed() -> void:
	selected_track_index += 1

## Intensity adjustment

## Sets the slider to the track's intensity property
func update_intensity_slider() -> void:
	var track = get_selected_track()
	if track:
		intensity_h_slider.value = track.intensity
		update_intensity_label(track)
		
## Sets the label's text to the slider's current value.
func update_intensity_label(track: DynamicMusicTrack = null) -> void:
	if track:
		intensity_slider_label.text = str(track.intensity) + "%"
	else:
		intensity_slider_label.text = str(intensity_h_slider.value) + "%"


func _on_intensity_h_slider_value_changed(value: float) -> void:
	update_intensity_label()

func _on_intensity_h_slider_drag_ended(value_changed: bool) -> void:
	var track = get_selected_track()
	if track:
		track.set_intensity(int(intensity_h_slider.value))
		update_intensity_label(track)
		
	#await get_tree().process_frame
	call_deferred(&"_update_synchronized_layers")
