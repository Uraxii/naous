class_name ChatInput extends View

enum {
    STATE_EDITING,
    STATE_HIDDEN,
}

var curr_state := STATE_HIDDEN

@onready var line: LineEdit = %ChatInput


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


func _on_submit(content: String) -> void:
    if line.text:
        var msg := MsgChat.new()
        msg.sender = InstanceAPI.local_player.character_name
        msg.message = content
        router.send(msg)

    line.text = ""
    hide()
    curr_state = STATE_HIDDEN


func _ready() -> void:
    signals.toggle_chat_input.connect(_on_accept)
    signals.ui_cancel.connect(_on_cancel)
    line.text_submitted.connect(_on_submit)
    hide()
