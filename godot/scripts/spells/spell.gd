class_name Spell extends Node

signal cast_started

@export var data: SpellData
@export var echo: EchoItem

@export var hotbar := 0
@export var hotbutton := 0
@export_category("Runtime Values")
@export var traits: Array[Trait] = []
@export var caster: Entity
@export var cast_cancel_token: String

@onready var router := Globals.msg_router
@onready var timer := Timer.new()

var icon: Texture2D:
    get: return data.icon

var id := "":
    get: return data.id

var is_castable: bool:
    get: return timer.time_left <= 0

var signals: SignalBus:
    get: return Globals.signal_bus


func setup(entity: Entity) -> void:
    caster = entity


func request_cast() -> void:
    var msg := MsgCastRequest.new()
    msg.spell_node_path = get_path()
    router.client_send_to_server(msg)

@rpc("reliable", "any_peer")
func start_cast(cast_token: String) -> void:
    cast_cancel_token = cast_token


@rpc("reliable", "any_peer")
func cast() -> void:
    cast_cancel_token = ""
    lg.debug("%d casted %s." % [caster.id, id])

    timer.wait_time = data.cooldown_time
    timer.start()
    cast_started.emit()

    for t in traits:
        if t:
            t.cast()


@rpc("reliable", "any_peer")
func cancel_cast() -> void:
    push_warning("Cancelling casts client logic has not been implemented yet.")


func get_all_traits() -> Array[Node]:
    var trait_nodes := get_children()
    
    var spell_traits: Array[Node] = []
    for t in trait_nodes:
        if t.has_method("cast"):
            if t.has_method("setup"):
                t.setup()
            spell_traits.append(t)

    return spell_traits


func generate_traits() -> Array[Trait]:
    var trait_nodes: Array[Trait] = []

    for trait_data in data.traits:
        var new_trait: Trait = trait_data.new()
        new_trait.name = trait_data.resource_name
        new_trait.setup(trait_data, self)
        add_child.call_deferred(new_trait)
        trait_nodes.append(new_trait)

    return trait_nodes


func _ready() -> void:
    traits = generate_traits()
    timer.one_shot = true
    add_child(timer)
