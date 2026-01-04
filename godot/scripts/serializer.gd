class_name Serializer


static func to_dict(obj: Object) -> Dictionary:
    var result : = {}

    result["type"] = obj.get_id()

    result["payload"] = {}
    var property_list = obj.get_script().get_script_property_list()
    for prop in property_list:
        if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var property_name = prop.name
            result["payload"][property_name] = obj.get(property_name)

    return result


static func from_dict(serialized_dict: Dictionary) -> Object:
    var script_type_id: BFT.ID = serialized_dict.get("type")
    var script := BFT.get_type(script_type_id)
    var obj = script.new()
    var payload: Dictionary = serialized_dict.get("payload")

    for prop in payload.keys():
        obj.set(prop, payload[prop])

    return obj
