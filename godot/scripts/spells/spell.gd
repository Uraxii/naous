class_name Spell extends Node

@export var id := ""
@export_category("Runtime Values")
@export var traits: Array[Node] = []


func cast() -> void:
    for t in traits:
        if t:
            t.cast()


func get_all_traits() -> Array[Node]:
    var trait_nodes := get_children()

    var spell_traits: Array[Node] = []
    for t in trait_nodes:
        if t.has_method("cast"):
            spell_traits.append(t)

    return spell_traits


#region Godot Callback Functions
func _ready() -> void:
    traits = get_all_traits()
#endregion
