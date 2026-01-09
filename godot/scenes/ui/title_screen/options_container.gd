extends MarginContainer

@onready var main_menu_tab: MarginContainer = %MenuContainer

func close() -> void:
	main_menu_tab.show()

const MASTER_BUS_IDX: int = 0
enum VOLUMES {
	MASTER,
	MUSIC,
}

@onready var vol_master_slider: HSlider = %MasterVolHSlider
@onready var vol_master_label_pct: Label = %MasterVolPercentLabel
@onready var vol_master_label_db: Label = %MasterVolDBLabel

@onready var vol_music_slider: HSlider = %MusicVolHSlider
@onready var vol_music_label_pct: Label = %MusicVolPercentLabel
@onready var vol_music_label_db: Label = %MusicVolDBLabel

func _ready() -> void:
	vol_master_slider.drag_ended.connect(_on_volume_slider_drag_ended.bind(VOLUMES.MASTER))
	vol_master_slider.value_changed.connect(_on_volume_slider_value_changed.bind(VOLUMES.MASTER))
	vol_music_slider.drag_ended.connect(_on_volume_slider_drag_ended.bind(VOLUMES.MUSIC))
	vol_music_slider.value_changed.connect(_on_volume_slider_value_changed.bind(VOLUMES.MUSIC))
	
	visibility_changed.connect(_on_visibility_changed)
	
func _on_visibility_changed() -> void:
	if visible:
		reset_music_sliders()

func reset_music_sliders() -> void:
	vol_master_slider.set_value(AudioServer.get_bus_volume_linear(MASTER_BUS_IDX) * 100.0)
	vol_music_slider.set_value(DynamicMusicManager.get_music_bus_volume_linear() * 100.0)
	
func _on_volume_slider_drag_ended(value_changed: bool, which:VOLUMES) -> void:
	if value_changed:
		match which:
			VOLUMES.MASTER:
				AudioServer.set_bus_volume_linear(MASTER_BUS_IDX, vol_master_slider.value / 100.0)
			VOLUMES.MUSIC:
				DynamicMusicManager.set_music_bus_volume(vol_music_slider.value / 100.0)

func _on_volume_slider_value_changed(value: float, which:VOLUMES) -> void:
	## Called every frame potentially as the slider is moved
	var rounded_percentage_as_text:String = "%d%%" % value
	var db_as_text:String = "%.1f" % linear_to_db(value / 100.0)
	match which:
		VOLUMES.MASTER:
			vol_master_label_pct.text = rounded_percentage_as_text
			vol_master_label_db.text = db_as_text
		VOLUMES.MUSIC:
			vol_music_label_pct.text = rounded_percentage_as_text
			vol_music_label_db.text = db_as_text


func _on_back_button_pressed() -> void:
	close()
