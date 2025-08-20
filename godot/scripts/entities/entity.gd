class_name Entity extends Node3D

#region Variables
signal change_control(is_local: bool)

const INVALID_ID: int = -1

# @export var data := EntityData.new()
@export var body: CharacterBody3D
@export var components: ComponentManager
@export_category("Runtime Values")
@export var id: int = INVALID_ID
@export var local_control := false : set = _set_local_control

@onready var entities := Globals.entities
@onready var projectile_spawner: Node3D = %ProjectileSpawner
#endregion


func get_component(type: GDScript) -> Node:
    return components.get_component(type)


func _set_local_control(value: bool) -> void:
    local_control = value
    change_control.emit(local_control)
        

#region Godot Callback Functions
func _ready() -> void:
    entities.spawn(self)


func _exit_tree() -> void:
    entities.despawn(self)
#endregion
