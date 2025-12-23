class_name ActorManager extends Node

@onready var signals := Globals.signal_bus

## Peer ID: Actor
var players: Dictionary[int, PlayerNew] = {  }
## Actor Instance ID: Actor
var actors: Dictionary[int, Actor] = {  }
var id_pool := IdPool.new()


func spawn_npc():
    pass


func spawn_player():
    pass


func on_network_tick() -> void:
    pass


func connect_signals() -> void:
    signals.network_tick.connect(on_network_tick)


func _ready() -> void:
    connect_signals()

