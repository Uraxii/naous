extends Node3D

@export var rotation_speed: float = 1.0 # Degrees per second

func _process(delta: float) -> void:
    rotation_degrees.y += rotation_speed * delta # For 3D Y-axis rotation
