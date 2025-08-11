class_name CameraManager extends SpringArm3D

@export var x_offset: float = 0.0
@export var y_offset: float = 2.0
@export var z_offset: float = 0.0
@export var zoom_increment: float = 2.0
@export var sensativity: float = 0.005
@export var target: Entity

@onready var signals = Globals.signal_bus
@onready var input = Globals.input


func _process(_delta: float) -> void:
    if not target:
        return

    position.x = target.body.position.x + x_offset
    position.y = target.body.position.y + y_offset
    position.z = target.body.position.z + z_offset

    if input.camera_zoom_out:
        spring_length += zoom_increment
    elif input.camera_zoom_in:
        spring_length -= zoom_increment

    if input.camera_rotation != Vector2.ZERO:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

        rotation.y -= input.camera_rotation.x * sensativity
        rotation.x -= input.camera_rotation.y * sensativity

        if rotation.x < -1:
            rotation.x = -1

        if input.camera_look:
            target.body.rotation.y = rotation.y

    elif !input.camera_rotate && !input.camera_look && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ready() -> void:
    signals.control_entity.connect(_on_control_entity)


func _on_control_entity(entity: Entity) -> void:
    print_debug("Set camera target to %s." % entity.id)
    target = entity
