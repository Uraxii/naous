# Tutorial
extends Node3D

@onready var tutorial_sequence: TutorialSequence = %TutorialSequence
@onready var first_enemy: Archa = %FirstEnemy


func _ready() -> void:
    # This is mostly to ensure we wait until the movement component warps the body up 100 units so we can snap it back after
    await get_tree().process_frame
    first_enemy.global_position = Vector3(0, -1000, 0)
    first_enemy.process_mode = Node.PROCESS_MODE_DISABLED
    tutorial_sequence.start()
