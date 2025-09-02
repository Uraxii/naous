class_name StateCameraFollow extends State

@onready var camera: CameraManager = get_owner()

var target: Entity:
    get: return camera.target

var input: InputManager:
    get: return Globals.input


func enter() -> void:
    next_state = StateCameraFollow


func process() -> void:
    if not target:
        next_state = StateCameraFree
        return

    camera.position = get_next_position(target)

    # Handle mouse motion
    if not camera.direction.is_zero_approx():
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

        _handle_rotation(camera.direction * camera.mouse_sensitivity)
        camera.direction = Vector2.ZERO

    # Handle controller joystick
    # - Can't drive this via signals since the joystick doesn't constantly emit events while
    #   actuated outside of neutral. So we just check the input directly. Not elegant, but works.
    elif not input.joystick_camera.is_zero_approx():
        var joystick_look := input.joystick_camera
        if camera.invert_look_y_axis:
            joystick_look *= Vector2(1, -1)

        _handle_rotation(camera.joystick_look * camera.joystick_sensitivity)

    # Handle menu
    elif camera.menu_is_open:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func exit() -> void:
    pass


func get_next_position(entity: Entity) -> Vector3:
    var new_position = Vector3(
        entity.body.global_position.x + camera.x_offset,
        entity.body.global_position.y + camera.y_offset,
        entity.body.global_position.z + camera.z_offset)

    return new_position


func _handle_rotation(rotation_vector: Vector2) -> void:
    camera.rotation.y -= rotation_vector.x
    camera.rotation.x -= rotation_vector.y

    if camera.rotation.x < -1:
        camera.rotation.x = -1

    target.body.rotation.y = camera.rotation.y
