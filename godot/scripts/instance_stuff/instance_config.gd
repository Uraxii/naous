class_name InstanceConfig extends Resource

@export var host    := "localhost"
@export var port    := 9000
@export var size    := 99
@export var disconnect_delay_sec := 300
@export var level := preload("res://scenes/world/zones/lake-natalie.tscn")
@export var player_scene := preload("res://scenes/entities/player.tscn")
@export var tick_rate := 30

var tick_interal: float:
    get: return 1.0 / tick_rate
