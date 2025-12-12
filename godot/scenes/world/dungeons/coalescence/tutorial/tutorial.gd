# Tutorial
extends Node3D

@onready var tutorial_sequence: TutorialSequence = %TutorialSequence
@onready var first_enemy: Archa = %FirstEnemy
@onready var pyramid_archa: Archa = %PyramidArcha
@onready var crystal_corner_archa: Archa = %CrystalCornerArcha
@onready var fountain_archa: Archa = %FountainArcha
@onready var miniboss_enemy: Archa = %MinibossEnemy
@onready var horde_enemy_1: Archa = %HordeEnemy1
@onready var horde_enemy_2: Archa = %HordeEnemy2
@onready var horde_enemy_3: Archa = %HordeEnemy3
@onready var backup_enemy_4: Archa = %BackupEnemy4
@onready var backup_enemy_5: Archa = %BackupEnemy5
@onready var backup_ally_1: Entity = %BackupAlly1
@onready var backup_ally_2: Entity = %BackupAlly2

const OFFSCREEN := Vector3(0, -1000, 0)
func _ready() -> void:
    # This is mostly to ensure we wait until the movement component warps the body up 100 units so we can snap it back after
    await get_tree().process_frame
    _move_enemies_offscreen()
    tutorial_sequence.start()


func _move_enemies_offscreen() -> void:
    var entities_to_hide := [
        first_enemy,
        pyramid_archa, crystal_corner_archa, fountain_archa,
        miniboss_enemy,
        horde_enemy_1, horde_enemy_2, horde_enemy_3,
        backup_enemy_4, backup_enemy_5,
        backup_ally_1, backup_ally_2,
    ]
    for to_hide: Entity in entities_to_hide:
        to_hide.body.global_position = OFFSCREEN
        to_hide.process_mode = Node.PROCESS_MODE_DISABLED
    
