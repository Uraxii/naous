class_name BFT

enum ID {
    UNKNOWN,
    COMP_ANIM,
    COMP_INFO,
    COMP_MOVE,
    COMP_SPELLBOOK,
    COMP_STATS,
    COMP_TARGETABLE,
    MSG_BASE,
    MSG_ACTOR_DATA,
    MSG_SPAWN_ACTOR,
    MSG_DELETE_ACTOR,
    MSG_UPDATE_ACTOR,
    MSG_TEST,
    MSG_CHAT,
    MSG_SPAWN_ENTITY,
    MSG_CAST_REQ,
    MSG_GET_ENTITY_DATA,
    TRAIT_DAMAGE_TARGET,
    TRAIT_SPAWN_ENTITY,
    TRAIT_SHOOT_PROJECTILE,
}

enum Err {
    OK = 0,
    ERR_ACTOR_NOT_FOUND,
}

enum Stat {
    DEX,
    CON,
    INT,
    STR,
}

enum EquipSlots {
    HEAD,
    NECK,
    BACK,
    SHOLDIER,
    CHEST,
    BELT,
    LEGS,
    RING_1,
    RING_2,
}


const id_to_type: Dictionary[ID, Resource] = {
    ID.COMP_ANIM: preload(
        "res://scripts/entities/components/component_animator.gd"),
    ID.COMP_INFO: preload(
        "res://test/actor_info_data.gd"),
    ID.COMP_MOVE: preload(
        "res://scripts/entities/components/component_move.gd"),
    ID.COMP_SPELLBOOK: preload(
        "res://scripts/entities/components/component_spellbook.gd"),
    ID.COMP_STATS: preload(
        "res://scripts/entities/components/component_stat_manager.gd"),
    ID.COMP_TARGETABLE: preload(
        "res://scripts/entities/targeting/targetable/targetable_screen_notifier.gd"),
    ID.MSG_BASE: preload(
        "res://scripts/messages/msg.gd"),
    ID.MSG_ACTOR_DATA: preload(
        "res://scripts/messages/msg_actor_data.gd"),
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

const err_strings: Dictionary = {
    Err.OK: "",
    Err.ERR_ACTOR_NOT_FOUND: "Unable to find an actor with that ID.",
}


static func get_type(type_id: ID) -> Resource:
    return id_to_type.get(type_id)


static func get_err_string(err_int: Err) -> String:
    return err_strings.get(err_int, "Error %d has no String!" % err_int)

