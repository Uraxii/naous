class_name ComponentMove extends Node

const FORCE_GRAVITY: float = 0.8
const FORCE_JUMP_GRAVIY: float = 0.4
const BACKPEDDLE_PENALTY := 0.75

var entity: Entity
var body: CharacterBody3D
var speed: StatComponent
var gravity: StatComponent
var jump_force: StatComponent

var signals: SignalBus:
    get: return Globals.signal_bus
    
var input: InputManager:
    get: return Globals.input

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
    move_velocity = body.transform.basis * Vector3(
        direction.x, 0, direction.y).normalized() * speed.current


func jump() -> void:
    if move_velocity.length() > 0.1:
        var horizontal_velocity = Vector3(move_velocity.x, 0, move_velocity.z)
        jump_influence = horizontal_velocity.normalized() * speed.current
    else:
        jump_influence = Vector3.ZERO
    
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
    current_velocity += jump_influence
    if jump_influence.y > 0:
        jump_influence.y -= FORCE_JUMP_GRAVIY
    return current_velocity


func apply_movement(current_velocity: Vector3) -> Vector3:
    current_velocity += move_velocity
    return current_velocity


func set_entity(new_entity: Entity) -> void:
    entity = new_entity


func _setup() -> void:
    var component_manager: ComponentManager = get_parent()
    if component_manager is not ComponentManager:
        push_error("Movement component MUST be child of a ComponentManager!")
        
    if not entity:
        entity = component_manager.entity
        if not entity: push_error("Movement found no entity!")
        
    body = entity.body
    push_warning("Reminder: Move is pushing the player up in _startup.")
    body.position.y += 100
    speed = entity.speed
    gravity = entity.gravity
    jump_force = entity.jump_force
    
    entity.change_control.connect(_on_change_control)
    
    if entity.transform_sync.is_multiplayer_authority() and not signals.jump.is_connected(jump):
        signals.jump.connect(jump)


func _on_change_control(local_has_control: bool):
    if local_has_control and not signals.jump.is_connected(jump):
        signals.jump.connect(jump)
    elif signals.jump.is_connected(jump):
        signals.jump.disconnect(jump)


#region Godot Callback Functions
func _ready() -> void:
    _setup.call_deferred()


func _process(_delta: float) -> void:
    if entity.transform_sync.is_multiplayer_authority():
        var dir = input.move
        if input.was_camera_move_enabled and dir.y == 0:
            dir.y = -1
        input_move(dir)

    body.velocity = apply_gravity(body.velocity)
    body.velocity = apply_jump_influence(body.velocity)
    body.velocity = apply_movement(body.velocity)

    if body.velocity.z < 0:
        body.velocity.z = body.velocity.z * BACKPEDDLE_PENALTY

    body.move_and_slide()
    body.velocity = Vector3.ZERO
#endregion
