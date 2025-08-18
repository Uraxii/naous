class_name Projectile extends RigidBody3D

var damage := 10.0
var speed := 20.0
var velocity = Vector3.ZERO
var spawner: Node3D


func setup(spawner_node:Node3D) -> void:
    spawner = spawner_node


func _ready() -> void:
    global_position = spawner.global_position
    global_rotation = spawner.global_rotation
    velocity = -transform.basis.z * speed


func _physics_process(delta) -> void:
    var collision = move_and_collide(velocity * delta)
    if collision:
        _hit_target(collision)
        

func _hit_target(collision) -> void:
    if collision is KinematicCollision3D:
        queue_free()
        return
    
    var hit_object = collision.collider
    
    # TODO: Damage
    
    queue_free()
