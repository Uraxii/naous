class_name Authorization

const SERVER_ID := 1


func is_authorized(peer_id: int, node: Node) -> bool:
    return peer_id == SERVER_ID or peer_id == node.get_multiplayer_authority()
