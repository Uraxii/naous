class_name MsgChat extends Msg

var sender: String
var message: String


func get_id() -> BFT.ID:
    return BFT.ID.MSG_CHAT
