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
@onready var escape_boss: BaseEnemy = %EscapeBoss
@onready var exit_loading_zone: Area3D = %ExitLoadingZone
@onready var tutorial_hotbar: TutorialHotbar = %TutorialHotbar
@onready var player: Player = %Player


const OFFSCREEN := Vector3(0, -1000, 0)
func _ready() -> void:
    # This is mostly to ensure we wait until the movement component warps the body up 100 units so we can snap it back after
    tutorial_sequence.spawn_entity_at.connect(_on_entity_spawn_at)
    tutorial_sequence.despawn_entity.connect(_on_entity_despawn)
    
    # Everything here happens after the first frame is done
    await get_tree().process_frame
    _move_entities_offscreen()
    exit_loading_zone.process_mode = Node.PROCESS_MODE_DISABLED
    tutorial_sequence.start()
    tutorial_hotbar.assign_entity(player)


func _move_entities_offscreen() -> void:
    var entities_to_hide := [
        first_enemy,
        pyramid_archa, crystal_corner_archa, fountain_archa,
        miniboss_enemy,
        horde_enemy_1, horde_enemy_2, horde_enemy_3,
        backup_enemy_4, backup_enemy_5,
        backup_ally_1, backup_ally_2,
        escape_boss
    ]
    for entity_to_hide: Entity in entities_to_hide:
        despawn_entity(entity_to_hide)


func despawn_entity(entity: Entity) -> void:
    Globals.logger.debug("Despawning entity %s" % [entity.name])
    if is_instance_valid(entity.body):
        entity.body.global_position = OFFSCREEN
        entity.body.hide()
    entity.process_mode = Node.PROCESS_MODE_DISABLED
    
    if is_instance_valid(player.targeting.current_target) and  player.targeting.current_target.entity == entity:
        player.targeting.clear_current_target()


func spawn_entity_at(entity: Entity, location: Vector3) -> void:
    Globals.logger.debug("Spawning entity %s at %s" % [entity.name, location])
    entity.global_position = location
    if is_instance_valid(entity.body):
        entity.body.global_position = location
        entity.body.show()
    entity.process_mode = Node.PROCESS_MODE_INHERIT
    entity.show()


func _on_entity_spawn_at(entity: Entity, location: Vector3) -> void:
    spawn_entity_at(entity, location)


func _on_entity_despawn(entity: Entity) -> void:
    despawn_entity(entity)
