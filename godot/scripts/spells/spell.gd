class_name Spell extends Node

signal cast_started

@export var data: SpellData

@export var hotbar := 1
@export var hotbutton := 1
@export_category("Runtime Values")
@export var traits: Array[Trait] = []
@export var caster: Entity
@export var cast_cancel_token: String

@onready var router := Globals.msg_router

var timer := Timer.new()

var icon: Texture2D:
    get: return data.icon

var id := "":
    get: return data.id

var is_castable: bool:
    get: return timer.time_left <= 0

var signals: SignalBus:
    get: return Globals.signal_bus


func setup(spell_data: SpellData, entity: Entity) -> void:
    data = spell_data
    caster = entity


func request_cast() -> void:
    var msg := MsgCastReq.new()
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


func generate_traits() -> Array[Trait]:
    var trait_nodes: Array[Trait] = []

    for trait_data in data.traits:
        print_debug("Loading trait: ", trait_data.resource_path)
        var new_trait: Trait = trait_data.trait_script.new()
        new_trait.name = trait_data.resource_path
        new_trait.setup(trait_data, self)
        trait_nodes.append(new_trait)
        add_child.call_deferred(new_trait)

    return trait_nodes


func _ready() -> void:
    hotbar = data.hotbar
    hotbutton = data.hotbutton

    traits = generate_traits()
    timer.one_shot = true
    add_child(timer)
