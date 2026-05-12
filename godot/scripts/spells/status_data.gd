class_name StatusData extends Resource

@export var id := ""
@export var spell: SpellData
@export var expiration_time := 1.0
@export var tick_rate := 1.0
@export var max_stacks := 1


func get_status_id() -> String:
    if not id.is_empty():
        return id
    if spell and not spell.id.is_empty():
        return spell.id
    return "status"


func serialize() -> Dictionary:
    var data := {}
    
    data["id"] = id
    data["expiration_time"] = expiration_time
    data["tick_rate"] = tick_rate
    data["max_stacks"] = max_stacks
    data["time"] = expiration_time
    data["max_charges"] = max_stacks

    if spell:
        data["spell_data"] = spell.serialize()
    else:
        data["spell_data"] = null

    return data


func deserialize(data: Dictionary) -> void:
    id = data.get("id", id)
    expiration_time = data.get("expiration_time", data.get("time", expiration_time))
    tick_rate = data.get("tick_rate", tick_rate)
    max_stacks = data.get("max_stacks", data.get("max_charges", max_stacks))

    var spell_dict = data.get("spell_data")
    if spell_dict and spell_dict is Dictionary:
        if not spell:
            spell = SpellData.new()
        spell.deserialize(spell_dict)
    elif spell_dict == null:
        spell = null
