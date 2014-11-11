__author__ = 'nightfade'

import asyncore
import sys

from network.tcp_server import TCPServer, TCPConnectionHandlerBase
from rpc.entity import RPCEntity, RPCService
from rpc.protobuf_rpc import PBRPCDeserializer, PBRPCSerializer


class EchoService(RPCService):

    def __init__(self, entity):
        super(EchoService, self).__init__()
        self.entity = entity

    def serve_method(self, method_name, params, callid):
        super(EchoService, self).serve_method(method_name, params, callid)
        self.entity.send_callback(callid, {'status': 'ok'})
        self.entity.call_method(method_name, params)

    def callback(self, callid, retvalue):
        super(EchoService, self).callback(callid, retvalue)


class RPCManager(TCPConnectionHandlerBase):

    def __init__(self):
        super(RPCManager, self).__init__()
        self.entities = {}

    def handle_new_connection(self, conn):
        super(RPCManager, self).handle_new_connection(conn)
        entity = RPCEntity(PBRPCSerializer(), PBRPCDeserializer())
        entity.set_connection(conn)
        entity.service = EchoService(entity)
        self.entities[conn.peername] = entity


class RPCServer(TCPServer):

    def __init__(self, ip, port):
        TCPServer.__init__(self, ip, port, RPCManager())


def main(ip, port):
    server = RPCServer(ip, port)
    while True:
        asyncore.loop()


if __name__ == '__main__':
    assert len(sys.argv) >= 3
    listen_ip = sys.argv[1]
    listen_port = int(sys.argv[2])
    main(listen_ip, listen_port)
