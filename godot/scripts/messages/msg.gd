class_name Msg

enum Type {
    UNKOWN,
    BASE,
    TEST,
    CHAT,
    SPAWN_ENTITY,
}

static var TypeMap: Dictionary[Type, GDScript] = {
    Type.BASE: Msg,
    Type.TEST: MsgTest,
    Type.CHAT: MsgChat,
    Type.SPAWN_ENTITY: MsgSpawnEntity,
}


func serialize() -> Dictionary:
    push_warning("serialize not implemented for message!")
    return { 
        "type": Type.BASE,
        "payload": {  },
    }


func deserialize(payload: Dictionary):
    push_warning("deserialize is not implemented on message!\tDATA:", payload)
