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
@export var target: Node3D
@export var camera_distance := 1.0 : set = _set_camera_distance

@onready var signals = Globals.signal_bus
@onready var input := Globals.input

@onready var camera: Camera3D = $Camera3D

var direction := Vector2.ZERO
var rotate_entity := false
var menu_is_open := false


func _ready() -> void:
    signals.control_entity.connect(_on_control_entity.call_deferred)
    signals.camera_zoom_out.connect(_on_camera_zoom_out)
    signals.camera_zoom_in.connect(_on_camera_zoom_in)
    signals.camera_rotate.connect(_on_camera_rotate)
    signals.character_rotate_start.connect(_on_character_rotate_start)
    signals.character_rotate_stop.connect(_on_character_rotate_stop)
    
    # Adjust position to make the server view better.
    # This can get deleted once free cam movement works.
    if multiplayer.is_server():
        position.x += 5
        position.y += 5
        
    # Ensure we have an active camera immediately
    camera.make_current()


func _handle_rotation(rotation_vector: Vector2) -> void:
    rotation.y -= rotation_vector.x
    rotation.x -= rotation_vector.y

    if rotation.x < -1: 
        rotation.x = -1

    target.body.rotation.y = rotation.y

#region Singal Handlers
func _set_camera_distance(value: float) -> void:
    camera_distance = clampf(value, min_distance, max_distance)
    spring_length = camera_distance


func _on_control_entity(entity: Entity) -> void:
    target = entity.components.find("Body")
    if not target:
        target = entity

    # Reassert camera after new target (in case another camera became current earlier)
    if not camera.is_current():
        camera.make_current()

func _on_camera_zoom_out() -> void:
    camera_distance += zoom_increment


func _on_camera_zoom_in() -> void:
    camera_distance -= zoom_increment


func _on_camera_rotate(input_direction: Vector2) -> void:
    direction = input_direction
    

func _on_character_rotate_start() -> void:
    rotate_entity = true
    

func _on_character_rotate_stop() -> void:
    rotate_entity = false
#endregion
