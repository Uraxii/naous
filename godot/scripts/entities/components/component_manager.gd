class_name ComponentManager extends Node

const ID := "Components"

@export var entity: Entity
@onready var map: Dictionary[String, Node] = get_all()


func get_all() -> Dictionary[String, Node]:
    var children = get_children()
    for child in children:
        _on_component_added(child)
    return map


func find(node_name: String) -> Node:
    var component = map.get(node_name)

    if is_instance_valid(component):
        component = find_child(node_name)
        if not component:
            return
        map.set(component.name, component)

    return component

#region Component Setup
func setup_move(move_comp: ComponentMove) -> void:
    var anim_comp: ComponentAnimator = find(ComponentAnimator.ID)
    if anim_comp:
        move_comp.moving.connect(anim_comp.moving)

    var stat_comp_signals: Dictionary[String, Callable] = {
        ComponentStat.SPEED_ID: move_comp.on_speed_change,
        ComponentStat.JUMP_FORCE_ID: move_comp.on_jump_force_change,
        ComponentStat.GRAVITY_ID: move_comp.on_gravity_change,
    }

    for stat_id in stat_comp_signals.keys():
        var comp: ComponentStat = find(stat_id)
        var signal_handler := stat_comp_signals[stat_id]
        # This initializes the value
        signal_handler.call(comp.current, comp.current)
        comp.change.connect(signal_handler)
#endregion

#region Signal Handler 
func connect_signals() -> void:
    child_entered_tree.connect(_on_component_added)
    child_exiting_tree.connect(_on_component_removed)


func _on_component_added(node: Node) -> void:
    map.set(node.name, node)
    print_debug("hello")
    match node.name:
        "Move":
            setup_move(node)


func _on_component_removed(node: Node) -> void:
    map.erase(node.name)
#endregion

#region Godot Callback Functions
func _ready() -> void:
    connect_signals()

    if not entity:
        entity = get_parent()
#endregion
