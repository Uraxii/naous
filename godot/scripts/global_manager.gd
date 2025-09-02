class_name GlobalManager extends Node

# Load order matters!!!
@onready var launch_args := ArgParser.parse()
@onready var signal_bus: SignalBus = new_global("Signals", SignalBus)
@onready var packets := PacketManager.new(signal_bus)
@onready var logger := Log.new(signal_bus)
@onready var input: InputManager = new_global("Input", InputManager)
@onready var views: ViewManager = new_global("Views", ViewManager)
@onready var game: GameManager = new_global("Game", GameManager)

@onready var interaction: InteractionManager = new_global(
    "Interaction", InteractionManager)

@onready var entities: EntityManager = new_global_scene(
    "Entities", preload("res://scenes/entity_manager.tscn"))

@onready var camera: CameraManager = new_global_scene(
    "Camera", preload("res://scenes/camera/camera_manager.tscn"))


func new_global(node_name: String, type: GDScript) -> Node:
    var global = type.new()
    global.name = node_name
    add_child(global)
    return global


func new_global_scene(node_name: String, scene: PackedScene) -> Node:
    var new_node = scene.instantiate()
    new_node.name = node_name
    add_child(new_node)
    return new_node
