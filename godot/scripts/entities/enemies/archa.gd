class_name Archa extends BaseEnemy

@onready var component_ai_movement: ComponentAIMovement = %ComponentAIMovement
@onready var player_detector: PlayerDetector = %PlayerDetector


func handle_player_detected(player: Player) -> void:
    component_ai_movement.move_toward_entity(player)


func handle_player_lost(player: Player) -> void:
    component_ai_movement.stop_following_entity()


func _ready() -> void:
    player_detector.player_detected.connect(handle_player_detected)
    player_detector.player_lost.connect(handle_player_lost)
