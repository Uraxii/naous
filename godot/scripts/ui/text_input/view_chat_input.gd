class_name ChatInput extends View

enum {
    STATE_EDITING,
    STATE_HIDDEN,
}

var curr_state := STATE_HIDDEN

@onready var line: LineEdit = %LineEdit


func _ready() -> void:
    signals.ui_accept.connect(_on_accept)
    signals.ui_cancel.connect(_on_cancel)
    line.text_submitted.connect(_on_submit)
    hide()


func _on_accept() -> void:
    match curr_state:
        STATE_HIDDEN:
            show()
            curr_state = STATE_EDITING


func _on_cancel() -> void:
    match curr_state:
        STATE_EDITING:
            hide()
            curr_state = STATE_HIDDEN


# TODO: Make this an rpc call and update messages for to clients.
func _on_submit(content: String) -> void:
    line.text = ""

    signals.chat.emit("You", content)
