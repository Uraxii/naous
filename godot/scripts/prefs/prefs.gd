class_name UserPrefs extends Resource

@export var fov := 100
@export var interface: InterfacePrefs


func serialize() -> Dictionary:
    var data = {}

    data["fov"] = fov

    if interface:
        data["interface"] = interface.serialize()

    return data


func deserialize(data: Dictionary) -> void:
    fov = data.get("fov", fov)
    var interface_data: Dictionary = data.get("interface", {})
    if not interface_data.is_empty():
        interface = InterfacePrefs.new()
        interface.deserialize(interface_data)
    else:
        if interface == null:
            interface = InterfacePrefs.new()
