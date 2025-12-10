class_name StatsData extends Resource

@export var health      := 100.0
@export var speed       := 10.0
@export var gravity     := 1.0
@export var jump_force  := 10.0


func serialize() -> Dictionary:
    return {
        "health":       health,
        "speed":        speed,
        "gravity":      gravity,
        "jump_force":   jump_force,
    }


func deserialize(data: Dictionary) -> void:
    health      = data.health
    speed       = data.speed
    gravity     = data.gravity
    jump_force  = data.jump_force
