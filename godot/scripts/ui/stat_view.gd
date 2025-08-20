class_name StatView extends View

@export var stat_id := ""
@export var label: Label


func _ready() -> void:
    var entity: Entity = get_parent()
    if not entity:
        return
        
    var stats: StatComponent = entity.get_component(StatComponent)
    if not stats:
        return
        
    var stat: Stat = stats.get_stat(stat_id)
    if not stat:
        return
        
    stat.change.connect(_on_change)
    _on_change(stat.current, stat.current)
    
    
func _on_change(new: float, _old: float) -> void:
    label.text = str(new)
