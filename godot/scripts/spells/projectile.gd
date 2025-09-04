class_name Projectile extends Entity

@export var damage := 10.0
@export var speed := 20.0
@export var rb: RigidBody3D

var velocity = Vector3.ZERO

func calculate_direction():
    velocity = -transform.basis.z * speed


func _ready() -> void:
    if not rb:
        rb = find_child("Body")


func _physics_process(delta) -> void:
    if not multiplayer.is_server():
        return
        
    var collision = rb.move_and_collide(velocity * delta)
    if collision:
        _hit_target(collision)
        

func _hit_target(collision: KinematicCollision3D) -> void:    
    var hit_object = collision.get_collider()
    print_debug("%s" % hit_object)
    
    if hit_object.name == "Body":
        var component_manager: ComponentManager = hit_object.get_parent()
        var entity: Entity = component_manager.entity
        var health: StatComponent = entity.components.find("Health")
        if health:
            health.current -= damage
    
    queue_free()
