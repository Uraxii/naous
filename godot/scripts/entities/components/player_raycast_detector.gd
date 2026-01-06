class_name PlayerRaycastDetector extends RayCast3D

signal in_range(player: Player)
signal out_of_range(player: Player)

@export var target_player: Player:
    set = set_target_player
@export var detection_distance: float = 0

var target_body: CharacterBody3D

var target_detected: bool = false


func _physics_process(delta: float) -> void:
    var collider := get_collider()
    
    # If we are detecting the target object and we weren't detecting anything before,
    # signal that we are currently detecting the object
    if collider == target_body and !target_detected:
        Globals.logger.debug("Player entered range of raycast")
        target_detected = true
        in_range.emit(target_player)
    
    # If we are not currently detecting anything and previously were detecting
    # the target object, signal that we are no longer detecting it.
    elif collider == null and target_detected:
        Globals.logger.debug("Player left range of raycast")
        target_detected = false
        out_of_range.emit(target_player)
    
    # Point at the player for the NEXT frame
    #var target_direction := global_position.direction_to(target_body.global_position)
    ##target_direction = target_direction.rotated()
    #target_position = target_direction * detection_distance
    look_at(target_body.global_position)


func set_target_player(player: Player) -> void:
    Globals.logger.debug("Setting new target player for raycast")
    target_player = player
    target_player.tree_exiting.connect(handle_player_exiting)
    var player_body: CharacterBody3D = target_player.body
    if player_body != null:
        target_body = player_body
        enabled = true
    else:
        Globals.logger.error("Attempting to detect a player with missing body!")
        target_body = null
        enabled = false


func handle_player_exiting() -> void:
    Globals.logger.debug("Target player is leaving scene, also freeing raycast")
    queue_free()


func _ready() -> void:
    enabled = target_body != null # Only enable if we have a valid body to detect
    collision_mask = 1 # The layer with the Player objects in it
    collide_with_areas = false
    hit_from_inside = true
    debug_shape_thickness = 4
    debug_shape_custom_color = Color(0.709, 0.616, 0.826, 0.85)
    target_position = Vector3.FORWARD * detection_distance
