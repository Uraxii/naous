class_name TestSaveData extends Node

@export var entity_data: EntityData


func run_test() -> bool:
    var serial_data := entity_data.serialize()
    print("Serialized Data: ", serial_data)

    entity_data.deserialize(serial_data)
    print("Inventory: ", entity_data.inventory.backpack)
    print("Spellbook: ")
    for spell in entity_data.spellbook.spells:
        print("\t %s" % spell.id)

    return true


func _ready() -> void:
    run_test()
