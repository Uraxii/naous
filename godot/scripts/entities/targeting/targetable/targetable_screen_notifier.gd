class_name TargetableScreenNotifier extends VisibleOnScreenNotifier3D

@onready var signals := Globals.signal_bus

var targetable: Targetable


func target_entered_screen() -> void:
    #print("target entered screen! - ", targetable)
    signals.target_entered_screen.emit(targetable)


func target_exited_screen() -> void:
    #print("target exited screen! - ", targetable)
    signals.target_exited_screen.emit(targetable)


#region Godot Callbacks
func _ready() -> void:
    screen_entered.connect(target_entered_screen)
    screen_exited.connect(target_exited_screen)
#endregion
