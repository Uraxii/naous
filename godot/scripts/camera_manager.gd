class_name CameraManager extends SpringArm3D
@export var sensativity := 0.005
@export var min_distance := -1.0
@export var max_distance := 20.0
@export var zoom_increment := 0.5
@export var x_offset := 0.5
@export var y_offset := 2.0
@export var z_offset := 0.0
@export_category("Runtime Values")
@export var target: Entity
@export var camera_distance := 1.0 : set = _set_camera_distance

@onready var signals = Globals.signal_bus
@onready var input = Globals.input

var direction := Vector2.ZERO
var menu_is_open := false


func _process(_delta: float) -> void:
    if not target:
        return

    position.x = target.body.position.x + x_offset
    position.y = target.body.position.y + y_offset
    position.z = target.body.position.z + z_offset

    if direction != Vector2.ZERO:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

        rotation.y -= direction.x * sensativity
        rotation.x -= direction.y * sensativity

        if rotation.x < -1:
            rotation.x = -1

        target.body.rotation.y = rotation.y
        direction = Vector2.ZERO
    elif menu_is_open:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ready() -> void:
    signals.control_entity.connect(_on_control_entity)
    signals.camera_zoom_out.connect(_on_camera_zoom_out)
    signals.camera_zoom_in.connect(_on_camera_zoom_in)
    signals.rotate_camera.connect(_on_rotate_camera)


func _set_camera_distance(value: float) -> void:
    camera_distance = clampf(value, min_distance, max_distance)
    spring_length = camera_distance


func _on_control_entity(entity: Entity) -> void:
    print_debug("Set camera target to %s." % entity.id)
    target = entity


func _on_camera_zoom_out() -> void:
    camera_distance += zoom_increment


func _on_camera_zoom_in() -> void:
    camera_distance -= zoom_increment


func _on_rotate_camera(input_direction: Vector2) -> void:
    direction = input_direction
