class_name EntityDetector extends Area3D

signal detecting_entity(entity: Entity)
signal lost_entity(entity: Entity)

@export var interactable: InteractableComponent

@onready var signals := Globals.signal_bus

var triggering_entities: Dictionary[int, Entity] # Map ID to Entity


#region Entity Detection
func add_detected_entity(new_entity: Entity) -> void:
    if not triggering_entities.has(new_entity.id):
        triggering_entities[new_entity.id] = new_entity
        detecting_entity.emit(new_entity)
        signals.entity_attempting_interaction.emit(new_entity, interactable)
    else:
        push_error("Already detecting Entity, can't add it again!")


func remove_detected_entity(entity_to_remove: Entity) -> void:
    if triggering_entities.has(entity_to_remove.id):
        triggering_entities.erase(entity_to_remove.id)
        lost_entity.emit(entity_to_remove)
    else:
        print("Can't remove Entity that is not being detected! Maybe OK?")
#endregion


#region Godot Callbacks
func _ready() -> void:
    #collision_layer = (1 << InteractionManager.INTERACTABLE_COLLISION_LAYER - 1)
    collision_mask = (1 << InteractionManager.ENTITY_COLLISION_LAYER - 1)
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
    var entity: Entity = body as Entity
    # TODO: Really hacky, need a better way to handle this
    if entity == null:
        entity = body.owner as Entity
    if entity != null:
        add_detected_entity(entity)


func _on_body_exited(body: Node3D) -> void:
    var entity: Entity = body as Entity
    # TODO: Really hacky, need a better way to handle this
    if entity == null:
        entity = body.owner as Entity
    if entity != null:
        remove_detected_entity(entity)
#endregion
