extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
func _on_item_selected(idx: int) -> void:
	match idx:
		0:
			## None
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		1:
			## FSR1
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		2:
			## FSR2
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
