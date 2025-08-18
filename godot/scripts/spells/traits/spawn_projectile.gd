class_name SpawnProjectile extends Node

@export var projectile_scene: PackedScene
@export_category("Runtime Values")
@export var spell: Spell
@export var projetile_spawner: Node3D


func setup() -> void:
    spell = get_parent()


func cast() -> void:
    projetile_spawner = spell.caster.projectile_spawner
    var projectile: Projectile = projectile_scene.instantiate()
    projectile.setup(projetile_spawner)
    get_tree().root.add_child.call_deferred(projectile)
