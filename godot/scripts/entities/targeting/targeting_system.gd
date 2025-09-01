class_name TargetingSystem extends Node

@export var detections: Array[TargetingDetection]

@onready var signals := Globals.signal_bus

var current_target: Node3D # TODO: Change to anything? Entity?


func cursor_target(screen_point: Vector2) -> void:
    print("Attempting to find target at cursor location: ", screen_point)


func next_target() -> void:
    
    pass


func previous_target() -> void:
    if not has_valid_target():
        next_target()
    else:
        # Find the previous target via reverse priority
        pass


func scan_target_right() -> void:
    pass


func scan_target_left() -> void:
    pass


func has_valid_target() -> bool:
    return is_instance_valid(current_target)


#region Godot Callbacks
func _ready() -> void:
    signals.cursor_target.connect(cursor_target)
    signals.next_target.connect(next_target)
    signals.previous_target.connect(previous_target)
    signals.scan_target_right.connect(scan_target_right)
    signals.scan_target_left.connect(scan_target_left)
#endregion
