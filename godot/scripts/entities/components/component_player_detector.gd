class_name PlayerDetector extends Node

signal player_detected(player: Player)
signal player_lost(player: Player)

@export var parent_entity: Entity
@export var detection_range: float = 10

var raycasts: Array[PlayerRaycastDetector]


func handle_player_detected(player: Player) -> void:
    player_detected.emit(player)


func handle_player_lost(player: Player) -> void:
    player_lost.emit(player)


func create_raycast_for_player(player: Player) -> PlayerRaycastDetector:
    var raycast := PlayerRaycastDetector.new()
    raycast.target_player = player
    raycast.detection_distance = detection_range
    raycast.in_range.connect(handle_player_detected)
    raycast.out_of_range.connect(handle_player_lost)
    return raycast


func handle_player_entered_scene(player: Player) -> void:
    var raycast := create_raycast_for_player(player)
    raycasts.push_back(raycast)
    
    if parent_entity.components != null:
        var parent_body: ComponentCharacterBody = parent_entity.body
        if is_instance_valid(parent_body):
            parent_body.add_child(raycast)


func handle_new_entity_spawned(entity: Entity) -> void:
    if entity is Player:
        handle_player_entered_scene(entity)


func _ready() -> void:
    if parent_entity == null:
        var component_parent: ComponentManager = get_parent()
        if is_instance_valid(component_parent) and component_parent.entity != null:
            parent_entity = component_parent.entity
        else:
            Globals.logger.error("Player detector has no encompassing parent entity!")
    
    Globals.signal_bus.spawn_entity.connect(handle_new_entity_spawned)
