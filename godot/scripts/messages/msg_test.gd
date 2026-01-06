class_name MsgTest extends MsgChat


func _init() -> void:
    sender = "Test"
    message = "This is a test message."


func get_id() -> BFT.ID:
    return BFT.ID.MSG_TEST
