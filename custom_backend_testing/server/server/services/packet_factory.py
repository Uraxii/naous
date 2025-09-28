from models.packets import *


class PacketFactory():
    @staticmethod
    def create_packet(packet_dict: dict) -> Packet:
        action: Action = packet_dict.get("action", Action.Malformed)
        peer_id: int = packet_dict.get("peer_id", 0)
        session_token: str = packet_dict.get("session_token", "")
        payloads: dict = packet_dict.get("payloads", {})
        payloads_type = globals()[f"{action}"]

        #print(f"constructor:{payloads_type}, action:{action}, payloads:{payloads}")

        packet = Packet[payloads_type](
            action=action,
            peer_id=peer_id,
            session_token=session_token,
            payloads=payloads_type(**payloads)
        )

        return packet
