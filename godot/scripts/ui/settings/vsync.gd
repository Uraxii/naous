extends OptionButton

func _ready() -> void:
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		select(1)
	else:
		select(0)
		
	item_selected.connect(_on_item_selected)
	
func _on_item_selected(idx: int) -> void:
	if idx == 0:
		## Vsync off
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	else:
		## Vsync on
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
