class_name HealthComponent extends StatComponent

@export var entity: Entity


func _on_value_change(new: float, _old: float) -> void:
    if new <= 0:
        entity.die()


func _ready() -> void:
    if not entity:
        push_error("HealthComponent is missing Entity assignment!")

    change.connect(_on_value_change)
