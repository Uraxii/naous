class_name ComponentAnimator extends AnimationTree

const ID := "Anim"

@export var movement_blend_parameter_path := ""
@export var jump_fall_blend_parameter_path := ""


func moving(velocity: Vector3) -> void:
    var v2_velocity = Vector2(velocity.x, velocity.z)
    set(movement_blend_parameter_path, v2_velocity)
    set(jump_fall_blend_parameter_path, velocity.y)


func jump() -> void:
    push_warning("jump anim not implemented.")


func falling() -> void:
    push_warning("falling anim not implemented.")


func land() -> void:
    push_warning("land anim not implemented.")


func weapon_swing() -> void:
    push_warning("weapon_swing not implemented.")


func start_cast() -> void:
    push_warning("start_cast anim not implemented.")


func cast() -> void:
    push_warning("cast anim not implemented.")


func take_damage() -> void:
    push_warning("take_damage anim not implemented.")


func low_health() -> void:
    push_warning("low_health anim not implemented")


func die() -> void:
    push_warning("die anim not implemented.")


func stunned() -> void:
    push_warning("stunned anim not implemented.")
