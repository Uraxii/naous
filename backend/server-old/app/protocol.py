import queue
import packet
from autobahn.twisted.websocket import WebSocketServerProtocol
from autobahn.exception import Disconnected
from typing import Callable


class GameServerProtocol(WebSocketServerProtocol):
    def __init__(self):
        super().__init__()
        self._packet_queue: queue.Queue[tuple['GameServerProtocol', packet.Packet]] = queue.Queue()
        self._state: Callable = self.PLAY
        self._known_others: set['GameServerProtocol'] = set()


    def PLAY(self, sender: 'GameServerProtocol', p: packet.Packet):
        pass


    def tick(self):
        # Process the next packet in the queue
        if not self._packet_queue.empty():
            s, p = self._packet_queue.get()
            self._state(s, p)


    def broadcast(self, p: packet.Packet, exclude_self: bool = False):
        for other in self.factory.players:
            if other == self and exclude_self:
                continue
            other.onPacket(self, p)


    def onConnect(self, request):
        print(f"Client connecting: {request.peer}")


    def onOpen(self):
        print(f"Websocket connection open.")


    def onClose(self, wasClean, code, reason):
        self.factory.remove_player(self)
        print(f"Websocket connection closed{' unexpectedly' if not wasClean else ' cleanly'} with code {code}: {reason}")


    def onMessage(self, payload, isBinary):
        decoded_payload = payload.decode('utf-8')

        try:
            p: packet.Packet | None = packet.from_json(decoded_payload)
        except Exception as e:
            print(f"Could not load message as packet: {e}. Message was: {payload.decode('utf8')}")

            return

        if p:
            self.onPacket(self, p)


    def onPacket(self, sender: 'GameServerProtocol', p: packet.Packet):
        self._packet_queue.put((sender, p))
        print(f"Queued packet: {p}")


    def send_client(self, p: packet.Packet):
        b = bytes(p)
        try:
            self.sendMessage(b)
        except Disconnected:
            print(f"Couldn't send {p} because client disconnected.")
