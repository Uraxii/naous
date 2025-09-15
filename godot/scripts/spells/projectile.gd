class_name Projectile extends Entity

@export var damage := 10.0

var velocity = Vector3.ZERO


func calculate_direction():
    velocity = -transform.basis.z * speed.current


func _physics_process(delta) -> void:
    if not multiplayer.is_server():
        return
        
    var collision = body.move_and_collide(velocity * delta)
    if collision:
        _hit_target(collision)
        

func _hit_target(collision: KinematicCollision3D) -> void:    
    var hit_object = collision.get_collider()
    
    var hit_entity: Entity = hit_object.get("entity")
    if not hit_entity:
        return
        
    if hit_entity.health:
        hit_entity.health.current -= damage
    
    queue_free()
