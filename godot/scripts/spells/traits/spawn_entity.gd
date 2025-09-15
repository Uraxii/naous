class_name TraitSpawnEntity extends Node

@export var entity_scene: PackedScene
@export_category("Runtime Values")
@export var spell: Spell

@onready var entities: EntityManager = Globals.entities


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    if not multiplayer.is_server():
        return
    
    var data = {
        "type": "projectile",
        "scene": entity_scene.resource_path,
        }
        
    var entity: Entity = entities.spawn(data)
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
