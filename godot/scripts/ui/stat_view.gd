class_name StatView extends View


@export var stat: Stat
@export var label: Label


func _ready() -> void:
    stat.change.connect(_on_change)
    _on_change(stat.current, stat.current)
    
    
func _on_change(new: float, _old: float) -> void:
    label.text = str(new)
