class_name TraitSpawnEntity extends Trait

@export var entity_scene: PackedScene
@export_category("Runtime Values")

@onready var router := Globals.msg_router
@onready var entities: EntityManager = Globals.entities


func cast() -> void:
    if not multiplayer.is_server():
        return

    var spawn_msg := MsgSpawnEntity.new()
    spawn_msg.resource_path = entity_scene.resource_path
    spawn_msg.position = spell.caster.body.global_position
    var entity: Entity = entities.spawn(spawn_msg.serialize())
    
    var glob_pos: Vector3 = spell.caster.body.global_position
    var glob_rot: Vector3 = spell.caster.body.global_rotation

    if not glob_pos:
        glob_pos = spell.caster.body.global_position
        glob_rot = spell.caster.body.global_rotation

    entity.position = glob_pos
    entity.rotation = glob_rot

    if entity is Projectile:
        entity.calculate_direction()

    entity.body.position = glob_pos
    entity.body.rotation = glob_rot
