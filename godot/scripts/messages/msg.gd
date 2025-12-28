class_name Msg

var err := BFT.Err.OK


func get_id() -> BFT.ID:
    return BFT.ID.MSG_BASE


func deserialize(payload_data: Dictionary) -> Msg:
    for property in payload_data.keys():
        if property in self:
            self.set(property, payload_data.get(property))

    return self 

