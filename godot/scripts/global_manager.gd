class_name GlobalManager extends Node

const SERVER_ID := 1

#region shared globals
var launch_args:    Dictionary
var signal_bus:     SignalBus
var msg_router:     MsgRouter
var save:           SaveManager
var logger:         Log
var input:          InputManager
var views:          ViewManager
var game:           GameManager
var interaction:    InteractionManager
var actors:         ActorManager
var entities:       EntityManager
var targeting:      TargetingManager
var camera:         CameraManager
var casting:        CastManager
var promises:       PromiseManager
#endregion

#region Client globals
var client: NaousNet
#endregion

#region Server globals
var server:         NaousNet
var instance_db:    InstanceDB
var actor_db:       ActorDB
#endregion


func new_global_script(node_name: String, type: GDScript) -> Node:
    var global = type.new()
    global.name = node_name
    add_child(global)
    return global


func new_global_scene(node_name: String, scene: PackedScene) -> Node:
    var new_node = scene.instantiate()
    new_node.name = node_name
    add_child(new_node)
    return new_node


func create_globals() -> void:
    # Load order matters!!!
    signal_bus = new_global_script("Signals", SignalBus)
    logger = new_global_script("Log", Log)
    msg_router = new_global_script("MsgRouter", MsgRouter)
    promises = new_global_script("Promises", PromiseManager)
    save = new_global_script("Save", SaveManager)
    input = new_global_script("Input", InputManager)
    views = new_global_script("Views", ViewManager)
    game = new_global_script("Game", GameManager)
    interaction = new_global_script("Interaction", InteractionManager)
    actors = new_global_script("Actors", preload("res://scripts/actors/actor_manager.gd"))
    entities = new_global_scene("Entities", preload("uid://c0kc2r2wbe47x"))
    targeting = new_global_script("Targeting", TargetingManager)
    camera = new_global_scene("Camera", preload("uid://dajlyyo0adshc"))
    casting = new_global_script("Casting", CastManager)


func create_server_globals() -> void:
    # Load order matters!!!
    push_warning("Initializing as server...")
    actor_db = new_global_script("ActorDB", ActorDB)
    instance_db = new_global_script("InstanceDB", InstanceDB)
    server = new_global_script("Network", preload("res://scripts/network/server_net.gd"))
    server.start_server()


func create_client_globals() -> void:
    # Load order matters!!!
    push_warning("Initializing as client...")
    client = new_global_script("Network", preload("res://scripts/network/client_net.gd"))
    views.spawn(CharacterSelectView)


func _ready():
    launch_args = ArgParser.parse()
    if launch_args.has("no-globals"):
        return

    create_globals()

    match launch_args.get("role", "client"):
        "server":
            create_server_globals()
        "client":
            create_client_globals()
        _:
            push_error(
                "%s is an invalid role! Check your launch arguments. Should be '--role=server' OR '--role=client'")


    views.spawn(ConsoleView)
