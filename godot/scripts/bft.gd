class_name BFT

enum ID {
    UNKNOWN,
    MSG_BASE,
    MSG_TEST,
    MSG_CHAT,
    MSG_SPAWN_ENTITY,
    MSG_CAST_REQ,
}

const id_to_type: Dictionary[ID, Resource] = {
    ID.MSG_BASE: preload("res://scripts/messages/msg.gd"),
    ID.MSG_TEST: preload("res://scripts/messages/msg_test.gd"),
    ID.MSG_CHAT: preload("res://scripts/messages/msg_chat.gd"),
    ID.MSG_SPAWN_ENTITY: preload("res://scripts/messages/msg_spawn_entity.gd"),
    ID.MSG_CAST_REQ: preload("res://scripts/messages/msg_cast_req.gd"),
}


static func get_type(type_id: ID) -> Resource:
    return id_to_type.get(type_id)
