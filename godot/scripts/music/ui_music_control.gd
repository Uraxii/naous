extends Control

## Allow the player to customize their listening experience
## Volume + select track playback

var manual_selection_tracks: Array[DynamicMusicTrack]

var instance_exists:bool:
	get:
		if Globals:
			if Globals.music:
				if is_instance_valid(Globals.music):
					return true
		return false

@onready var music_options_panel: PanelContainer = %MusicOptionsPanel

@onready var volume_h_slider: HSlider = %VolumeHSlider
@onready var volume_percentage_label: Label = %VolumePercentageLabel

@onready var track_select_menu_button: MenuButton = %TrackSelectMenuButton
@onready var continuous_playback_check_box: CheckBox = %ContinuousPlaybackCheckBox

@onready var tracks_item_list: ItemList = %TracksItemList

func _ready() -> void:
	music_options_panel.hide()
	
	if instance_exists:
		## Populate TrackSelectOptionButton items
		track_select_menu_button.get_popup().index_pressed.connect(_on_track_select_menu_button_item_selected)
		
		manual_selection_tracks.assign(Globals.music.current_playlist)
		
		var this_track_id:int = 0
		for track in manual_selection_tracks:
			this_track_id += 1
			track_select_menu_button.get_popup().add_item(track.title, this_track_id)
			var this_idx = track_select_menu_button.get_popup().get_item_index(this_track_id)
			## Set the metadata for that item to the index of the track in our export property
			track_select_menu_button.get_popup().set_item_metadata(this_idx, manual_selection_tracks.find(track))
			
			var this_list_idx: int = tracks_item_list.add_item(track.title)
			tracks_item_list.set_item_metadata(this_list_idx, manual_selection_tracks.find(track))
			#if track.include_in_continuous_playlist: ## DEPRECATED
			tracks_item_list.select(this_list_idx, false)
			
		## Populate Continuous Playback
		continuous_playback_check_box.button_pressed = Globals.music.continuous_playback
		tracks_item_list.visible = continuous_playback_check_box.button_pressed
	
func _on_close_window_button_pressed() -> void:
	music_options_panel.hide()

func _on_music_button_pressed() -> void:
	if not instance_exists:
		push_warning("DynamicMusicManager instance not found.")
		
	volume_h_slider.set_value(DynamicMusicManager.get_music_bus_volume_linear() * 100.0)
	
	music_options_panel.show()


func _on_volume_h_slider_drag_ended(value_changed: bool) -> void:
	## Called when drag ended
	if value_changed:
		## Set the music bus volume
		DynamicMusicManager.set_music_bus_volume(volume_h_slider.value / 100.0)


func _on_volume_h_slider_value_changed(value: float) -> void:
	## Called every frame potentially as the slider is moved
	var rounded_percentage:int = roundi(value)
	volume_percentage_label.text = str(rounded_percentage) + "%"


func _on_track_select_menu_button_item_selected(index: int) -> void:
	## Play the selected track
	var track: DynamicMusicTrack = manual_selection_tracks.get(
		track_select_menu_button.get_popup().get_item_metadata(index)
		)
	
	if track:
		if instance_exists:
			Globals.music.start_track(track)


func _on_continuous_playback_check_box_toggled(toggled_on: bool) -> void:
	continuous_playback_check_box.text = "(on)" if toggled_on else "(off)"
	if instance_exists:
		Globals.music.continuous_playback = toggled_on
		tracks_item_list.visible = toggled_on


func _on_tracks_item_list_multi_selected(index: int, selected: bool) -> void:
	## Set the DynamicMusicTrack's property pertaining to continous play
	var track: DynamicMusicTrack = manual_selection_tracks.get(
		tracks_item_list.get_item_metadata(index)
		)
	
	if track:
		if selected:
			manual_selection_tracks.erase(track)
		else:
			manual_selection_tracks.append(track)
		
		if not manual_selection_tracks.is_empty():
			Globals.music.start_playlist(manual_selection_tracks)
		#track.include_in_continuous_playlist = selected ## DEPRECATED
