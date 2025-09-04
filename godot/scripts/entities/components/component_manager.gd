class_name ComponentManager extends Node

@export var entity: Entity
@onready var map: Dictionary[String, Node] = get_all()


func get_all() -> Dictionary[String, Node]:
    var component_map: Dictionary[String, Node]= {}
    var children = get_children()
    for child in children:
        component_map.set(child.name, child)
    return component_map
    

func find(node_name: String) -> Node:
    return map.get(node_name)


#region Signal Handler Functions
func _on_component_added(node: Node) -> void:
    map.set(node.name, node)
    
func _on_component_removed(node: Node) -> void:
    map.erase(node.name)
#endregion 

#region Godot Callback Functions
func _ready() -> void:
    child_entered_tree.connect(_on_component_added)
    child_exiting_tree.connect(_on_component_removed)
    
    if not entity:
        entity = get_parent()
#endregion
