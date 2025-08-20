class_name ComponentManager extends Node

@onready var components: Dictionary[GDScript, Node] = get_components()


func get_component(type: GDScript) -> Node:
    if not components.has(type):
        components = get_components()

    return components.get(type)


func get_components() -> Dictionary[GDScript, Node]:
    var component_nodes := get_children()

    var map: Dictionary[GDScript, Node] = {}
    for node in component_nodes:
        map[node.get_script()] = node

    return map
