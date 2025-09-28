extends Control

@export var non_positional_root: Node
@export var positional_root: Node3D

@export var tracks:Array[DynamicMusicTrack]

@export_group("Prototypes", "proto_")
@export var proto_non_positional_player:AudioStreamPlayer
@export var proto_positional_player:AudioStreamPlayer3D

var selected_track_index:int = 0:
	set(value):
		if tracks.size() > 0:
			selected_track_index = wrapi(value, 0, tracks.size())
			selected_track_label.text = tracks[selected_track_index].title
		else:
			selected_track_index = -1
			selected_track_label.text = "No tracks!"

@onready var selected_track_label: Label = %SelectedTrack
@onready var controller_sync_layers: PanelContainer = %ControllerSyncLayers # parent of vbox for layers


func start_track(track:DynamicMusicTrack) -> void:
	var player = get_player(track)
	player.play()
	
	if track.file is AudioStreamSynchronized:
		repopulate_synchronized_layers(player.stream)
		controller_sync_layers.show()
	else:
		controller_sync_layers.hide()
		
	if track.trans_start_fade_in:
			pass
	
func stop_track(track:DynamicMusicTrack) -> void:
	var player = get_player(track)
	player.stop()
		
	if track.trans_end_fade_out:
			player.volume_linear = track.trans_start_fade_in.sample_baked(track.trans_end_fade_out.min_domain)
			var trans_tween:Tween = player.create_tween()
			trans_tween.tween_method(DynamicMusicTrack.set_volume_from_curve.bind(player, track.trans_end_fade_out), player.volume_linear, track.trans_end_fade_out.max_domain, track.trans_end_fade_out.max_domain)
	
func get_player(track:DynamicMusicTrack) -> Variant:
	if track.treat_positional:
		
		for player:AudioStreamPlayer3D in positional_root.get_children():
			if player.stream == track.file:
				return player
				
		## New 3D Player
		var new_player:AudioStreamPlayer3D
		new_player = proto_positional_player.duplicate()
		
		new_player.stream = track.file
		new_player.bus = track.MUSIC_BUS
		
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
		new_player.bus = track.MUSIC_BUS
		
		non_positional_root.add_child(new_player)
		return new_player
	
func repopulate_synchronized_layers(stream:AudioStreamSynchronized) -> void:
	var vbox:VBoxContainer = controller_sync_layers.get_child(0)
	for child in vbox.get_children():
		if child is CheckButton:
			child.free()
	for i in stream.stream_count:
		var layer:AudioStream = stream.get_sync_stream(i)
		# Make a toggle
		var check_button := CheckButton.new()
		check_button.text = layer.resource_path.get_file() # This is just for UI purposes.
		check_button.button_pressed = true # All streams always start playing at once by default.
		check_button.toggled.connect(_on_sync_check_button_toggled.bind(stream, i))
		vbox.add_child(check_button)
	pass
	
func _on_sync_check_button_toggled(is_pressed:bool, stream:AudioStreamSynchronized, id:int) -> void:
	stream.set_sync_stream_volume(id, linear_to_db(1.0 if is_pressed else 0.0))

func _on_start_playback_pressed() -> void:
	start_track(tracks[selected_track_index])
		
func _on_stop_playback_pressed() -> void:
	stop_track(tracks[selected_track_index])


func _on_track_select_prev_pressed() -> void:
	selected_track_index -= 1

func _on_track_select_next_pressed() -> void:
	selected_track_index += 1
