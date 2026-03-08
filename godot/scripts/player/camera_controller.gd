extends Camera3D

var _last_mouse_pos: Vector2

func _input(event):
    if event.is_action_pressed("drag_camera"):
        _last_mouse_pos = get_viewport().get_mouse_position()
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event.is_action_released("drag_camera"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        # Restore mouse position after unhiding to prevent reset
        get_viewport().warp_mouse(_last_mouse_pos)
