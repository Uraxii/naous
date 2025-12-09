class_name MsgModifyStat extends Msg

var sender: String
var message: String


func serialize() -> Dictionary:
    return {
        "type": Type.CHAT,
        "payload": {
            "sender": sender,
            "message": message,
        }
    }


func deserialize(payload: Dictionary):
    sender = payload.sender
    message = payload.message
