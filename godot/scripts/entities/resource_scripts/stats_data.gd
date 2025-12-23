class_name StatsData extends Resource

@export var health      := 100.0
@export var speed       := 10.0
@export var gravity     := 1.0
@export var jump_force  := 10.0


func serialize() -> Dictionary:
    return {
        ComponentStat.HEALTH_ID:        health,
        ComponentStat.SPEED_ID:         speed,
        ComponentStat.GRAVITY_ID:       gravity,
        ComponentStat.JUMP_FORCE_ID:    jump_force,
    }


func deserialize(data: Dictionary) -> void:
    health      = data.get(ComponentStat.HEALTH_ID, health)
    speed       = data.get(ComponentStat.SPEED_ID, speed)
    gravity     = data.get(ComponentStat.GRAVITY_ID, gravity)
    jump_force  = data.get(ComponentStat.JUMP_FORCE_ID, jump_force)
