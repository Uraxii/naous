class_name CastManager extends Node

@onready var signals := Globals.signal_bus
@onready var entities := Globals.entities

@export var queue: Dictionary[String, Spell] = {}


func _on_cast_request(msg: MsgCastRequest) -> void:
    var spell: Spell = get_node(msg.spell_node_path)
    if not spell:
        return

    var spell_node_path := str(spell.get_path())
    var cast_request: Spell = queue.get(spell_node_path)
    if cast_request:
        queue.erase(spell_node_path)
        cast_request.cancel_cast.rpc()
        return

    queue[spell_node_path] = spell
    var cast_token := spell.get_path()
    spell.start_cast.rpc(cast_token)


func process_queue() -> void:
    if queue.size() == 0:
        return

    var stack: Array[Spell] = queue.values().duplicate()
    queue.clear()

    for spell in stack:
        lg.debug("Casting %s", spell.name)
        spell.cast.rpc()


func connect_signals() -> void:
    signals.network_tick.connect(process_queue)
    signals.cast_resquest_msg.connect(_on_cast_request)


#region Godot Callback Functions
func _ready() -> void:
    connect_signals()
#endregion
