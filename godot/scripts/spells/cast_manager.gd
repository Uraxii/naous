class_name CastManager extends Node

@onready var signals := Globals.signal_bus
@onready var entities := Globals.entities

#region Signal Handlers
func connect_signals() -> void:
    signals.damage_entity.connect(_on_damage_entity)


func _on_damage_entity(entity_id: int, amount: float) -> void:
    lg.debug("%d damage on %d" % [amount, entity_id])
    var entity := entities.find(entity_id)
    if not entity or not entity.health:
        return

    entity.health.current -= amount
#endregion


#reagion Godot Callback Functions
func _ready() -> void:
    connect_signals()
#endregion
