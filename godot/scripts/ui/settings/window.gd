extends Control

@onready var windowed_option_button: OptionButton = $WindowedOptionButton
@onready var resolution_option_button: OptionButton = $ResolutionOptionButton

func _ready() -> void:
	windowed_option_button.item_selected.connect(_on_windowed_option_selected)
	resolution_option_button.item_selected.connect(_on_resolution_selected)

func _on_resolution_selected(item_idx: int) -> void:
	var text: String = resolution_option_button.get_item_text(item_idx)
	var halves: PackedStringArray = text.split("x", false)
	print(halves)
	get_tree().root.size = Vector2i(
		int(halves[0]), int(halves[1])
		)

func _on_windowed_option_selected(item_idx: int) -> void:
	match item_idx:
		0:
			## Windowed
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_tree().root.mode = Window.MODE_WINDOWED
		1:
			## Borderless FS
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			get_tree().root.mode = Window.MODE_FULLSCREEN
		2:
			## Exclusive FS
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			get_tree().root.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
