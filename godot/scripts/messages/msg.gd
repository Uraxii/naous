class_name Msg

var promise_id: int = -1


func get_id() -> BFT.ID:
    return BFT.ID.MSG_BASE


func deserialize(payload_data: Dictionary):
    for property in payload_data.keys():
        if property in self:
            self.set(property, payload_data.get(property))
