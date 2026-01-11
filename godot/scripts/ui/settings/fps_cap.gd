extends LineEdit

func _ready() -> void:
	text_submitted.connect(_on_text_submitted)
	_populate()
	
func _populate() -> void:
	if Engine.max_fps == 0:
		text = ""
	else:
		text = str(Engine.max_fps)
	
func _on_text_submitted(_text: String) -> void:
	var value: int = int(_text)
	if not value >= 30:
		Engine.max_fps = 0
	else:
		Engine.max_fps = value
	
	_populate()
