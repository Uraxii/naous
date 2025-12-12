class_name ComponentManager extends Node

@export var entity: Entity
@onready var map: Dictionary[String, Node] = get_all()


func get_all() -> Dictionary[String, Node]:
    var component_map: Dictionary[String, Node]= {}
    var children = get_children()
    for child in children:
        _on_component_added(child)
    return component_map


func find(node_name: String) -> Node:
    var component = map.get(node_name)

    if not component:
        component = find_child(node_name)
        map.set(component.name, component)

    return component

#region Component Setup
func setup_move(move_comp: ComponentMove) -> void:
    print_debug("Setting up move component.")
    var anim_comp: ComponentAnimator = find("Animator")
    if anim_comp:
        move_comp.moving.connect(anim_comp.moving)
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
