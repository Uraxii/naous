class_name GlobalManager extends Node

@onready var launch_args := ArgParser.parse()

@onready var signal_bus := SignalBus.new()
@onready var log        := Log.new(signal_bus)
@onready var packets    := PacketManager.new(signal_bus)
@onready var input      := PlayerInput.new()
@onready var views      := ViewManager.new()
@onready var game       := GameManager.new()
@onready var camera: CameraManager = preload(
    "res://scenes/camera_manager.tscn").instantiate()


func _ready() -> void:
    if launch_args.has("no-globals"):
        return

    # Load order matters here!
    input.name = "Input"
    add_child(input)
    views.name = "View"
    add_child(views)
    game.name = "Game"
    add_child(game)
    camera.name = "Camera"
    add_child(camera)
