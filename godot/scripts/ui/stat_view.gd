class_name StatView extends View

@export var stat_type: String
@export var label: Label


func _ready() -> void:
    var entity: Entity = get_parent()
    if not entity:
        return
        
    var stat: StatComponent = entity.get_component(HealthComponent)
    
    stat.change.connect(_on_change)
    _on_change(stat.current, stat.current)
    
    
func _on_change(new: float, _old: float) -> void:
    label.text = str(new)
