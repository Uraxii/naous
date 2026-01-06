class_name ComponentVisual extends Node3D

@export var body: CharacterBody3D


func _process(delta: float) -> void:
    if not body:
        return

    position = body.position
    rotation = body.rotation
