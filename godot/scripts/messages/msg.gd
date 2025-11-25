class_name Msg

enum Type {
    UNKOWN,
    BASE,
    TEST,
    SPAWN_ENTITY,
}

var type := Type.BASE
var data := {  }


static func serialize(msg: Msg) -> Dictionary:
    return {
        "type": msg.type,
        "data": msg.data,
    }


static func deserialize(serialized_msg: Dictionary) -> Msg:
    var msg = Msg.new()
    msg.type = serialized_msg.get("type", Type.UNKOWN)
    msg.data = serialized_msg.get("data", {  })
    return msg
