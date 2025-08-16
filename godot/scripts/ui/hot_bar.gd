class_name HotkeyBar extends View

@export var binds := ["action_1", "action_2", "action_3", "action_0"]

var buttons: Array[HotkeyButton] = []


func _ready() -> void:
    for i in range(0, binds.size()):
        var button = HotkeyButton.new()
        button.set_bind(signals.get(binds[i]))
        buttons.append(button)
        add_child(button)
