class_name EntityData extends Resource

@export var id:         EntityIdData
@export var stats:      StatsData
@export var inventory:  Inventory


func serialize() -> Dictionary:
    return {
        "id":           id.serialize(),
        "stats":        stats.serialize(),
        "inventory":    inventory.serialize(),
    }


func deserialize(data: Dictionary) -> void:
    for data in
