class_name InteractionManager extends Node

# TODO: Refactor this to a CollisionManager
# - Note that these are set in ProjectSettings -> 3D Physics (prop name: layer_names/3d_physics/layer_X)
const PLAYER_COLLISION_LAYER := 1
const ENTITY_COLLISION_LAYER := 3
const INTERACTABLE_COLLISION_LAYER := 4

@onready var signals := Globals.signal_bus

var interaction_detection_map: Dictionary[InteractableComponent, Array]

var interaction_map: Dictionary[InteractableComponent, Array]


#region Interaction Management
func entity_can_interact(entity: Entity, interactable: InteractableComponent) -> void:
    pass


func entity_attempting_interaction(entity: Entity, interactable: InteractableComponent) -> void:
    var entity_interaction: InteractionComponent = entity.get_component(InteractionComponent)
    if entity_interaction != null:
        # TODO: Can add logic here for the scenario where the player CAN interact (ie. see the prompt), but fails to due to a condition of sorts
        entity_interaction.start_interaction_with(interactable)


func entity_started_interaction(entity: Entity, interactable: InteractableComponent) -> void:
    interactable.interact()


func entity_interaction_interrupted(entity: Entity, interactable: InteractableComponent) -> void:
    pass
    
    
func entity_completed_interaction(entity: Entity, interactable: InteractableComponent) -> void:
    pass


func entity_lost_interactable(entity: Entity, interactable: InteractableComponent) -> void:
    pass
#endregion


#region Callbacks and Signals
func _ready() -> void:
    _connect_signals()

func _connect_signals() -> void:
    signals.entity_can_interact.connect(entity_can_interact)
    signals.entity_attempting_interaction.connect(entity_attempting_interaction)
    signals.entity_started_interaction.connect(entity_started_interaction)
    signals.entity_interaction_interrupted.connect(entity_interaction_interrupted)
    signals.entity_completed_interaction.connect(entity_completed_interaction)
    signals.entity_lost_interactable.connect(entity_lost_interactable)
#endregion
