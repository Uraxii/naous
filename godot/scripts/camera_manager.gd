class_name CameraManager extends SpringArm3D
@export var mouse_sensitivity := 0.005
@export var joystick_sensitivity := 0.06
@export var invert_look_y_axis := false
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
@onready var input := Globals.input

var direction := Vector2.ZERO
var menu_is_open := false


func _process(_delta: float) -> void:
    if not target:
        return

    position.x = target.body.position.x + x_offset
    position.y = target.body.position.y + y_offset
    position.z = target.body.position.z + z_offset
    
    # Handle mouse motion
    if not direction.is_zero_approx():
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

        _handle_rotation(direction * mouse_sensitivity)
        direction = Vector2.ZERO
    # Handle controller joystick
    elif not input.joystick_camera.is_zero_approx():
        var joystick_look := input.joystick_camera
        if invert_look_y_axis:
            joystick_look *= Vector2(1, -1)
        _handle_rotation(joystick_look * joystick_sensitivity)
    # Handle menu
    elif menu_is_open:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ready() -> void:
    signals.control_entity.connect(_on_control_entity)
    signals.camera_zoom_out.connect(_on_camera_zoom_out)
    signals.camera_zoom_in.connect(_on_camera_zoom_in)
    signals.rotate_camera.connect(_on_rotate_camera)


func _handle_rotation(rotation_vector: Vector2) -> void:
    rotation.y -= rotation_vector.x
    rotation.x -= rotation_vector.y

    if rotation.x < -1:
        rotation.x = -1

    target.body.rotation.y = rotation.y


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
