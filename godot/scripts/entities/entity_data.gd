class_name EntityData extends Resource

@export var id := EntityIdData.new()
@export var prefs := UserPrefs.new()
@export var stats := StatsData.new()
@export var inventory := Inventory.new()
@export var spellbook := SpellbookData.new()


func serialize() -> Dictionary:
    return {
        "id":           id.serialize(),
        "stats":        stats.serialize(),
        "inventory":    inventory.serialize(),
        "spellbook":    spellbook.serialize(),
    }


func deserialize(data: Dictionary) -> EntityData:
    var id_data = data.get("id")
    if id_data:
        id.deserialize(id_data)
    else:
        id = EntityIdData.new()

    var stats_data = data.get("stats")
    if stats_data:
        stats.deserialize(stats_data)
    else:
        stats = StatsData.new()

    var inventory_data = data.get("inventory")
    if inventory_data:
        inventory.deserialize(inventory_data)
    else:
        inventory = Inventory.new()

    var spellbook_data = data.get("spellbook")
    if spellbook_data:
        spellbook.deserialize(spellbook_data)
    else:
        spellbook = SpellbookData.new()

    return self
