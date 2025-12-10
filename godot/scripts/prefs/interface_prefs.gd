class_name InterfacePrefs extends Resource

@export var opacity := 1.0
@export var scale := 1.0
@export var hotbars: Array[HotbarData] = [HotbarData.new()]


func serialize() -> Dictionary:
    var data = {}

    data["opacity"] = opacity
    data["scale"] = scale

    var serialized_hotbars: Array[Dictionary] = []
    for hotbar in hotbars:
        serialized_hotbars.append(hotbar.serialize())

    data["hotbars"] = serialized_hotbars
    return data


func deserialize(data: Dictionary) -> void:
    opacity = data.get("opacity", opacity)
    scale = data.get("scale", scale)

    var saved_hotbars_data: Array[Dictionary] = data.get("hotbars", [])
    hotbars.clear() 
    for hotbar_data in saved_hotbars_data:
        var new_hotbar: HotbarData = HotbarData.new()
        new_hotbar.deserialize(hotbar_data)
        hotbars.append(new_hotbar)
