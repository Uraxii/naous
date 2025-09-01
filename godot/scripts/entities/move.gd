class_name Move extends Node

const FORCE_GRAVITY: float = 0.8
const FORCE_JUMP_GRAVIY: float = 0.4
const BACKPEDDLE_PENALTY := 0.75


@export var entity: Entity
@export var body: CharacterBody3D

@onready var signals = Globals.signal_bus
@onready var input = Globals.input
@onready var speed: SpeedComponent = entity.get_component(SpeedComponent)
@onready var gravity: GravityComponent = entity.get_component(GravityComponent)
@onready var jump_force: JumpForceComponent = entity.get_component(
    JumpForceComponent)

var current_gravity: float = 0.0
var move_velocity := Vector3.ZERO
var is_jumping: bool = false
var jump_influence := Vector3.ZERO


func set_force_movement(velocity: Vector3) -> void:
    move_velocity = velocity


func move_towards(position: Vector3) -> void:
    var direction = position - body.global_transform.origin
    direction = direction.normalized()
    move_velocity = direction * speed.current


func input_move(direction: Vector2):
    #print_debug(input.move)
    move_velocity = body.transform.basis * Vector3(
        direction.x, 0, direction.y).normalized() * speed.current


func jump() -> void:
    jump_influence = body.transform.basis * Vector3(
        move_velocity.x, 0, move_velocity.y).normalized()

    jump_influence = jump_influence * speed.current
    jump_influence.y = jump_force.current


func apply_gravity(current_velocity: Vector3) -> Vector3:
    if body.is_on_floor():
        current_gravity = 0
        current_velocity.y = 0
        return current_velocity

    var gravity_to_apply: float

    if is_jumping and jump_influence.y > 0:
        gravity_to_apply = FORCE_JUMP_GRAVIY
    else:
        gravity_to_apply = FORCE_GRAVITY

    current_gravity -= gravity_to_apply * gravity.current
    current_velocity.y += current_gravity

    return current_velocity


func apply_jump_influence(current_velocity: Vector3) -> Vector3:
    if is_jumping and body.is_on_floor() or jump_influence == Vector3.ZERO:
        is_jumping = false
        jump_influence = Vector3.ZERO
        return current_velocity

    is_jumping = true
    # print_debug('Current jump influence y %3f' % jump_influence.y)
    current_velocity += jump_influence

    if jump_influence.y > 0:
        jump_influence.y -= FORCE_JUMP_GRAVIY

    return current_velocity


func apply_movement(current_velocity: Vector3) -> Vector3:
    current_velocity += move_velocity
    return current_velocity


#region Godot Callback Functions
func _ready() -> void:
    entity.change_control.connect(_on_change_control)


func _process(_delta: float) -> void:
    if entity.is_multiplayer_authority():
        input_move(input.move)

    body.velocity = apply_gravity(body.velocity)
    body.velocity = apply_jump_influence(body.velocity)
    body.velocity = apply_movement(body.velocity)

    if body.velocity.z < 0:
        body.velocity.z = body.velocity.z * BACKPEDDLE_PENALTY

    body.move_and_slide()

    body.velocity = Vector3.ZERO
#endregion

#region Signal Handlers
func _on_change_control(local_has_control: bool):
    # TODO: Refactor this.
    if local_has_control:
        if not signals.jump.is_connected(_on_input_jump):
            signals.jump.connect(_on_input_jump)
    else:
        if signals.jump.is_connected(_on_input_jump):
            signals.jump.disconnect(_on_input_jump)


func _on_input_jump():
    jump()

#endregion
