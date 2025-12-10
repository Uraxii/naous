class_name HotbuttonData extends Resource

@export var button_id := 0
@export var enabled := true
@export var opacity := 1.0
@export var scale := 1.0
# Action strings found in InputBindings class
@export var action_bind: Array[String] = []
@export var spell_id := ""


func serialize() -> Dictionary:
    var data = {}

    data["enabled"] = enabled
    data["button_id"] = button_id
    data["action_bind"] = action_bind
    data["spell_id"] = spell_id

    return data


func deserialize(data: Dictionary) -> void:
    enabled = data.get("enabled", enabled)
    button_id = data.get("button_id", button_id)
    action_bind = data.get("action_bind", action_bind)
    spell_id = data.get("spell_id", spell_id)
