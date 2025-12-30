class_name Serializer


## Converts object to a dictionary that can be sent as input via RPC.
static func to_dict(obj: Object) -> Dictionary:
    var result := {
        "type": obj.get_id(),
        "payload": {},
    }

    var property_list = obj.get_script().get_script_property_list()
    for prop in property_list:
        if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var property_name = prop.name
            var property_value = obj.get(property_name)

            if prop is Object and property_value.has_method("serialize"):
                property_value = property_value.serialize()

            result["payload"][property_name] = obj.get(property_name)

    return result


## Converts a serialized object from a dictionary to its Object type.
static func from_dict(serialized_dict: Dictionary) -> Object:
    var script_type_id: BFT.ID = serialized_dict.get("type")
    var script := BFT.get_type(script_type_id)
    if not script:
        lg.error("No script for BFT.ID %d! Make sure the Dictionary in bft.gd is up-to-date." % script_type_id)
        return

    var obj = script.new()
    var payload: Dictionary = serialized_dict.get("payload")

    for prop_name in payload.keys():
        var prop = obj.get(prop_name)
        var value = payload[prop_name]

        if prop is Object and prop.has_method("deserialize"):
            value = prop.deserialize(value)
            continue

        prop = value

    return obj
