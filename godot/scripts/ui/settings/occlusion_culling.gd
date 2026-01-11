extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
func _on_item_selected(idx: int) -> void:
	if idx == 0:
		## On
		get_viewport().use_occlusion_culling = true
	else:
		## Off
		get_viewport().use_occlusion_culling = false
