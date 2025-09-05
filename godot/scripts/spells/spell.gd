class_name Spell extends Node

signal cast_started

@export var id := ""
@export var cooldown_time := 1.0
@export var hotbar := 0
@export var hotbutton := 0
@export_category("Runtime Values")
@export var traits: Array[Node] = []
@export var caster: Entity

@onready var timer := Timer.new()


var is_castable: bool:
    get: return timer.time_left <= 0

var signals: SignalBus:
    get: return Globals.signal_bus


func setup(entity: Entity) -> void:
    caster = entity


@rpc("call_local", "reliable")
func cast() -> void:
    signals.log_new_debug.emit("%d casted %s." % [caster.id, id])
    timer.wait_time = cooldown_time
    timer.start()
    cast_started.emit()
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


func _ready() -> void:
    traits = get_all_traits()
    timer.one_shot = true
    add_child(timer)
