class_name ComponentAnimator extends AnimationTree

@export var movement_blend_parameter_path := ""
@export var jump_fall_blend_parameter_path := ""


func moving(velocity: Vector3) -> void:
    var v2_velocity = Vector2(velocity.x, velocity.z)
    set(movement_blend_parameter_path, v2_velocity)
    set(jump_fall_blend_parameter_path, velocity.y)

func jump() -> void:
    pass


func falling() -> void:
    pass


func land() -> void:
    pass


func weapon_swing() -> void:
    pass


func start_cast() -> void:
    pass


func cast() -> void:
    pass


func take_damage() -> void:
    pass


func low_health() -> void:
    pass


func stunned() -> void:
    pass
