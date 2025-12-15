class_name HotbarData extends Resource

@export var id := 0
@export var scale := 1.0
@export var opacity := 1.0
@export var buttons: Array[HotbuttonData] = []


func serialize() -> Dictionary:
    var data = {}

    data["buttons"] = []
    for hotbutton in buttons:
        data["buttons"].append(hotbutton.serialize())

    data["scale"] = scale
    return data


func deserialize(data: Dictionary) -> void:
    scale = data.get("scale", scale)
    var saved_buttons_data: Array[Dictionary] = data.get("buttons", [])
    buttons.clear()
    for button_data in saved_buttons_data:
        var new_hotbutton: HotbuttonData = HotbuttonData.new()
        new_hotbutton.deserialize(button_data)
        buttons.append(new_hotbutton)
