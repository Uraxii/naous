class_name GameManager extends Node

@export var hotbar_manager_scene: PackedScene = load(
    "res://scenes/ui/hotbar_manager.tscn")

@onready var signals: SignalBus = Globals.signal_bus
@onready var views: ViewManager = Globals.views


func _ready() -> void:
    signals.connected_to_server.connect(_on_connected_to_server)


func _on_connected_to_server() -> void:
    var hotbar_manager: HotbarManager = views.spawn_menu(hotbar_manager_scene)
    hotbar_manager.add_bar()
