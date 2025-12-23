class_name MsgGetEntityData extends Msg

var entity_id: int


func get_type() -> BFT.ID:
    return BFT.ID.MSG_GET_ENTITY_DATA
