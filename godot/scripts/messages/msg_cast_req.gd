class_name MsgCastReq extends Msg

var spell_node_path := ""

func get_id() -> BFT.ID:
    return BFT.ID.MSG_CAST_REQ
