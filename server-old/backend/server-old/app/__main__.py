import sys
import os
from twisted.python import log
from twisted.internet import reactor, task
from twisted.internet.endpoints import TCP4ServerEndpoint
from autobahn.twisted.websocket import WebSocketServerFactory

import protocol


class GameFactory(WebSocketServerFactory):
    def __init__(self, hostname: str, port: int):
        # Change the protocol from 'wss://' to 'ws://'
        super().__init__(f"ws://{hostname}:{port}")

        self.protocol = protocol.GameServerProtocol
        self.players: set[protocol.GameServerProtocol] = set()
        self.tickrate: int = 20
        self.user_ids_logged_in: set[int] = set()

        tickloop = task.LoopingCall(self.tick)
        tickloop.start(1 / self.tickrate)

    def tick(self):
        for p in self.players:
            p.tick()

    def remove_protocol(self, p: protocol.GameServerProtocol):
        self.players.remove(p)
        if p._actor and p._actor.user.id in self.user_ids_logged_in:
            self.user_ids_logged_in.remove(p._actor.user.id)

    # Override
    def buildProtocol(self, addr):
        p = super().buildProtocol(addr)
        self.players.add(p)
        return p


if __name__ == '__main__':
    log.startLogging(sys.stdout)

    PORT: int = 8081
    factory = GameFactory('0.0.0.0', PORT)

    # Create a standard TCP endpoint and listen
    endpoint = TCP4ServerEndpoint(reactor, PORT)
    endpoint.listen(factory)

    reactor.run()
