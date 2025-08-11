class_name GlobalManager extends Node

# Load order matters!!!
@onready var launch_args := ArgParser.parse()
@onready var log := Log.new(signal_bus)
@onready var packets := PacketManager.new(signal_bus)
@onready var signal_bus: SignalBus = create_global("Signals", SignalBus)
@onready var input: InputManager = create_global("Input", InputManager)
@onready var views: ViewManager = create_global("Views", ViewManager)
@onready var game: GameManager = create_global("Game", GameManager)
@onready var entities: EntityManager = create_global("Entities", EntityManager)
@onready var camera: CameraManager = preload(
    "res://scenes/camera_manager.tscn").instantiate()


func create_global(node_name: String, type: GDScript) -> Node:
    var new_global = type.new()
    new_global.name = node_name
    add_child(new_global)
    return new_global


func _ready() -> void:
    camera.name = "Camera"
    add_child(camera)
