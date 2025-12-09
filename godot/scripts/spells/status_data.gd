class_name status_data extends Resource

@export var id := ""
@export var spell: SpellData
@export var time := 1.0
@export var max_charges := 1


func serialize() -> Dictionary:
    var data := {}
    
    data["id"] = id
    data["time"] = time
    data["max_charges"] = max_charges

    if spell:
        data["spell_data"] = spell.serialize()
    else:
        data["spell_data"] = null

    return data


func deserialize(data: Dictionary) -> void:
    id = data.get("id", id)
    time = data.get("time", time)
    max_charges = data.get("max_charges", max_charges)
    var spell_dict = data.get("spell_data")
    spell.deserialize(spell_dict)
