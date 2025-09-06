class_name HotbarManager extends Control

@export var default_hotbar_prefs: HotbarPrefs
@export var hotbar_scene: PackedScene
@onready var signals: SignalBus = Globals.signal_bus

var active: Array[HotbarView]


func add_bar() -> HotbarView:
    var bar = hotbar_scene.instantiate()
    add_child.call_deferred(bar)
    active.append(bar)
    return bar
