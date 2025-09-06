class_name HealthComponent extends StatComponent

var entity: Entity


func _set_current(value: float) -> void:
    if is_infinite:
        return
        
    var old = current
    current = clamp(value, min_value, max_value)
    change.emit(current, old)
    
    if value <= 0:
        entity.die()
        

func _setup() -> void:
    var component_manager: ComponentManager = get_parent()
    entity = component_manager.entity
    if not entity:
        push_error("HealthComponent is missing Entity assignment!")
        

func _ready() -> void:
    _setup.call_deferred()
