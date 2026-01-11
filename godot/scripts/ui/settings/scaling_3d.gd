extends Control

@onready var value_edit: LineEdit = $ValueLineEdit
@onready var h_slider: HSlider = $HSlider

func _ready() -> void:
	h_slider.value_changed.connect(_on_h_slider_value_changed)
	value_edit.text_submitted.connect(_on_value_edit_text_submitted)
	_get_settings()
	
func _get_settings() -> void:
	var _actual = ProjectSettings.get_setting("rendering/scaling_3d/scale", 1.0)
	
	h_slider.set_value_no_signal(_actual)
	value_edit.text = str(_actual)

func _on_debounce_finished() -> void:
	ProjectSettings.set_setting("rendering/scaling_3d/scale", h_slider.value)
	get_viewport().scaling_3d_scale = h_slider.value
	await get_tree().process_frame
	_get_settings()
	
var debouncer:Tween
func _on_h_slider_value_changed(value: float) -> void:
	if debouncer:
		if debouncer.is_valid():
			return
			
	debouncer = create_tween()
	debouncer.tween_interval(0.25)
	debouncer.tween_callback(_on_debounce_finished)
	
func _on_value_edit_text_submitted(entry: String) -> void:
	h_slider.value = float(entry)
