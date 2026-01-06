class_name ComponentAIMovement extends Node

@export var entity: Entity
@export var body: CharacterBody3D
@export var speed: ComponentStat
@export var gravity: ComponentStat

# TODO: Later implement a proper NavigationMesh system with NavigationAgent3D
var target_destination: Vector3:
    set = set_target_destination
var target_entity: Entity
var has_target: bool = false


func move_in_direction(direction: Vector3) -> void:
    var destination := body.global_position + direction
    target_destination = destination
    target_entity = null


func move_towards_global_position(destination_position: Vector3) -> void:
    target_destination = destination_position
    target_entity = null


func move_toward_entity(destination_entity: Entity) -> void:
    target_entity = destination_entity


func stop_following_entity() -> void:
    target_entity = null
    stop_moving_toward_target()


func stop_moving_toward_target() -> void:
    target_destination = Vector3.ZERO
    has_target = false


# TODO: Use NavigationAgent to set the "target_position" here and let the nav logic do the rest
func set_target_destination(new_destination: Vector3) -> void:
    target_destination = new_destination
    has_target = true


# TODO: Use NavigationAgent "get_next_path_position()" to resolve where to go next
func _get_next_position() -> Vector3:
    var next_position: Vector3
    if is_instance_valid(target_entity):
        target_destination = target_entity.body.global_position
    
    if not target_destination.is_zero_approx():
        next_position = target_destination
    return next_position


func _physics_process(delta: float) -> void:
    var next_position := _get_next_position()
    var target_velocity := Vector3.ZERO
    if not next_position.is_zero_approx():
        # Don't rotate up/down facing
        body.look_at(Vector3(next_position.x, body.global_position.y, next_position.z)) 
        # TODO: Update this with acceleration or whatever later
        target_velocity = body.global_position.direction_to(next_position) * speed.current
    
    body.velocity = target_velocity
    body.velocity.y -= gravity.current
    body.move_and_slide()


func _ready() -> void:
    if entity == null:
        var component_parent: ComponentManager = get_parent()
        if is_instance_valid(component_parent) and component_parent.entity != null:
            entity = component_parent.entity
        else:
            Globals.logger.error("AI Movement has no encompassing parent entity!")
