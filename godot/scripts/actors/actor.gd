class_name Actor extends Node

const INVALID_ID := 0

enum Kind {
    BASE,
    NPC,
    PLAYER,
}

@export var comp_man: ComponentManager

var id: int = INVALID_ID

var kind: Kind:
    get = get_kind


func get_kind() -> Kind:
    push_error("get_kind not implemented on %s" % get_path())
    return Kind.BASE


func set_data(data) -> void:
    push_error("set_data not implemented on %s" % get_path())


func disable() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED


func setup_component_manager() -> void:
    comp_man = find_child(ComponentManager.ID)
    if not comp_man:
        push_error("%s has no component manager!" % get_path())
        disable()


func _ready() -> void:
    if not comp_man:
        setup_component_manager()

