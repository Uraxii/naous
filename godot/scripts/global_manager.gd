class_name GlobalManager extends Node

const SERVER_ID := 1

var launch_args:    Dictionary
var signal_bus:     SignalBus
var save:           SaveManager
var logger:         Log
var input:          InputManager
var views:          ViewManager
var game:           GameManager
var interaction:    InteractionManager
var entities:       EntityManager
var targeting:      TargetingManager
var camera:         CameraManager
var casting:        CastManager


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
    input = new_global_script("Input", InputManager)
    views = new_global_script("Views", ViewManager)
    game = new_global_script("Game", GameManager)
    interaction = new_global_script("Interaction", InteractionManager)
    entities = new_global_scene("Entities", preload("uid://c0kc2r2wbe47x"))
    targeting = new_global_script("Targeting", TargetingManager)
    camera = new_global_scene("Camera", preload("uid://dajlyyo0adshc"))
    casting = new_global_script("Casting", CastManager)
    save = new_global_script("Save", SaveManager)


func _ready():
    launch_args = ArgParser.parse()
    if not launch_args.has("no-globals"):
        create_globals()
