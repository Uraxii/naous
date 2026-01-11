extends Control

@onready var h_slider: HSlider = $HSlider
@onready var value_line_edit: LineEdit = $ValueLineEdit

func _ready() -> void:
	h_slider.value_changed.connect(_on_h_slider_value_changed)
	value_line_edit.text_changed.connect(_on_value_line_edit_text_changed)
	_populate()

func _populate() -> void:
	h_slider.value = get_tree().root.content_scale_factor
	
func apply(value) -> void:
	get_tree().root.content_scale_factor = value
	ProjectSettings.set_setting("display/window/stretch/scale", value)
	
	value_line_edit.text = str(value)

func _on_h_slider_value_changed(value) -> void:
	apply(value)

func _on_value_line_edit_text_changed(text) -> void:
	_on_h_slider_value_changed(float(text))
