extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
func _on_item_selected(idx: int) -> void:
	get_viewport().anisotropic_filtering_level = get_item_id(idx) as Viewport.AnisotropicFiltering
	print("Aniso set to ", get_viewport().anisotropic_filtering_level)
