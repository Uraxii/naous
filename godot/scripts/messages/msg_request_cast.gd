class_name MsgCastRequest extends Msg

var spell_node_path := ""


func serialize() -> Dictionary:
    return {
        "type": Type.CAST_REQUEST,
        "payload": {
            "spell_node_path": spell_node_path
        }
    }


func deserialize(payload: Dictionary):
    spell_node_path = payload.spell_node_path
