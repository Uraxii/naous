class_name BFT

enum ID {
    UNKNOWN,
    MSG_BASE,
    MSG_TEST,
    MSG_CHAT,
    MSG_SPAWN_ENTITY,
    MSG_CAST_REQ,
    MSG_GET_ENTITY_DATA,
    TRAIT_DAMAGE_TARGET,
    TRAIT_SPAWN_ENTITY,
    TRAIT_SHOOT_PROJECTILE,
}

const id_to_type: Dictionary[ID, Resource] = {
    ID.MSG_BASE: preload(
        "res://scripts/messages/msg.gd"),
    ID.MSG_TEST: preload(
        "res://scripts/messages/msg_test.gd"),
    ID.MSG_CHAT: preload(
        "res://scripts/messages/msg_chat.gd"),
    ID.MSG_SPAWN_ENTITY: preload(
        "res://scripts/messages/msg_spawn_entity.gd"),
    ID.MSG_CAST_REQ: preload(
        "res://scripts/messages/msg_cast_req.gd"),
    ID.MSG_GET_ENTITY_DATA: preload(
        "res://scripts/messages/msg_get_entity_data.gd"),
    ID.TRAIT_DAMAGE_TARGET: preload(
        "res://scripts/spells/traits/damage_target.gd"),
    ID.TRAIT_SPAWN_ENTITY: preload(
        "res://scripts/spells/traits/spawn_entity.gd"),
    ID.TRAIT_SHOOT_PROJECTILE: preload(
        "res://scripts/spells/traits/trait_shoot_projectile.gd"),
}


static func get_type(type_id: ID) -> Resource:
    return id_to_type.get(type_id)
