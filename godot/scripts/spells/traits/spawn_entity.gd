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
    var rb: RigidBody3D = entity.components.find("Body")
    rb.freeze = true
    var glob_pos: Vector3 = spell.caster.components.find("Body").find_child("ProjectileSpawner").global_position
    var glob_rot: Vector3 = spell.caster.components.find("Body").find_child("ProjectileSpawner").global_rotation
    if not glob_pos:
        glob_pos = spell.caster.components.find("Body").global_position
        glob_rot = spell.caster.components.find("Body").global_rotation
    entity.position = glob_pos
    entity.rotation = glob_rot
    if entity is Projectile:
        entity.calculate_direction()
    rb.position = glob_pos
    rb.rotation = glob_rot
    rb.freeze = false
