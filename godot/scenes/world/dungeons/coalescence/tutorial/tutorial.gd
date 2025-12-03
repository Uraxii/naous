# Tutorial
extends Node3D

@onready var tutorial_sequence: TutorialSequence = %TutorialSequence
@onready var first_enemy: Archa = %FirstEnemy
@onready var pyramid_archa: Archa = %PyramidArcha
@onready var crystal_corner_archa: Archa = %CrystalCornerArcha
@onready var fountain_archa: Archa = %FountainArcha

const OFFSCREEN := Vector3(0, -1000, 0)
func _ready() -> void:
    # This is mostly to ensure we wait until the movement component warps the body up 100 units so we can snap it back after
    await get_tree().process_frame
    _move_enemies_offscreen()
    tutorial_sequence.start()


func _move_enemies_offscreen() -> void:
    var enemies := [
        first_enemy,
        pyramid_archa, crystal_corner_archa, fountain_archa,
    ]
    for enemy: Archa in enemies:
        enemy.global_position = OFFSCREEN
        enemy.process_mode = Node.PROCESS_MODE_DISABLED
    
