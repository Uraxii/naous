class_name StateCameraAnimated extends State

@onready var camera: CameraManager = get_owner()

var animation_player: AnimationPlayer:
    get: return # TODO

var input: InputManager:
    get: return Globals.input


var last_mouse_pos: Vector2

func enter() -> void:
    # Store mouse position before any state changes
    last_mouse_pos = DisplayServer.mouse_get_position()
    next_state = StateCameraAnimated


func process() -> void:
    if not animation_player or not animation_player.is_inside_tree():
        next_state = StateCameraFree
        return

    ## TODO set camera.position to match a Marker animated by the player?

    ## Handle mouse motion -- probably do nothing
    #if not camera.direction.is_zero_approx():
        #_handle_rotation(camera.direction * camera.mouse_sensitivity)
        #camera.direction = Vector2.ZERO

    ## Handle controller joystick
    ## - Can't drive this via signals since the joystick doesn't constantly emit events while
    ##   actuated outside of neutral. So we just check the input directly. Not elegant, but works.
    #elif not input.joystick_camera.is_zero_approx():
        #var joystick_look := input.joystick_camera
        #if camera.invert_look_y_axis:
            #joystick_look *= Vector2(1, -1)
#
        #_handle_rotation(joystick_look * camera.joystick_sensitivity)

    ## Handle menu
    elif camera.menu_is_open:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        # Restore mouse position to prevent jumping
        if last_mouse_pos != Vector2.ZERO:
            DisplayServer.mouse_set_position(last_mouse_pos)


func exit() -> void:
    pass

## DEPRECATED
func get_next_position(position: Vector3) -> Vector3:
    var new_position = Vector3(
        position.x + camera.x_offset,
        position.y + camera.y_offset,
        position.z + camera.z_offset
        )

    return new_position


## DEPRECATED
func _handle_rotation(rotation_vector: Vector2) -> void:
    camera.rotation.y -= rotation_vector.x
    camera.rotation.x -= rotation_vector.y

    if camera.rotation.x < -1:
        camera.rotation.x = -1
    
    #if camera.rotate_entity:
        #target.rotation.y = camera.rotation.y
