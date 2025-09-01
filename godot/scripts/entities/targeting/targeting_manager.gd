class_name TargetingManager extends Node

signal player_targeted(player: Entity, target: Targetable)

const INDICATOR: PackedScene = preload("uid://b74mdgvt321do") # targeting_indicator.tscn

@onready var globals := Globals


func find_targetable() -> Targetable:
    return null


func body_is_in_projected_polygon(body: Node3D, polygon: Polygon2D) -> bool:
    return false 
    

func _find_targetable_at_screen_position(screen_pos: Vector2) -> Targetable:
    return null


func _find_targetable_nearest_position(screen_pos: Vector2) -> Targetable:
    return null
