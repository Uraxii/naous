class_name Spell extends Node

@export var id := ""
@export_category("Runtime Values")
@export var traits: Array[Node] = []
@export var caster: Entity

var signals: SignalBus:
    get: return Globals.signal_bus


func setup(entity: Entity) -> void:
    caster = entity


func can_cast() -> bool:
    return true


@rpc("call_local", "reliable")
func cast() -> void:
    signals.log_new_debug.emit("%d casted %s" %[caster.id, id])
    for t in traits:
        if t:
            t.cast()


func get_all_traits() -> Array[Node]:
    var trait_nodes := get_children()

    var spell_traits: Array[Node] = []
    for t in trait_nodes:
        if t.has_method("cast"):
            if t.has_method("setup"):
                t.setup()
            spell_traits.append(t)


    return spell_traits


#region Godot Callback Functions
func _ready() -> void:
    traits = get_all_traits()
#endregion
