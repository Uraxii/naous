class_name SpellbookData extends Resource

@export var spells: Array[SpellData]


func serialize() -> Dictionary:
    var data := {}
    var serialized_spells = []

    for spell in spells:
        if spell and spell.has_method("serialize"):
            serialized_spells.append(spell.serialize())

    data["spells"] = serialized_spells

    return data


func deserialize(data: Dictionary) -> void:
    var spells_data_array: Array = data.get("spells", [])

    spells.clear()

    for spell_dict in spells_data_array:
        if not spell_dict is Dictionary:
            continue

        var new_spell = SpellData.new()
        new_spell.deserialize(spell_dict)
        spells.append(new_spell)
