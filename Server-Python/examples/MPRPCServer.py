__author__ = 'nightfade'

import asyncore
import sys

from network.tcp_server import TCPServer, TCPConnectionHandlerBase
from rpc.entity import RPCEntity
from rpc.base import RPCServiceBase, RPCResponse
from rpc.msgpack.rpc_codec import MPRPCCodec
from utility import logger_manager


class EchoService(RPCServiceBase):

    def __init__(self):
        super(EchoService, self).__init__()
        self.entity = None
        self.logger = logger_manager.get_logger(self.__class__.__name__)

    def set_entity(self, entity):
        self.entity = entity

    def handleRequest(self, request):
        response = RPCResponse()
        response.callid = request.callid
        response.retvalue = {'status': 'ok'}

        def callback(retvalue):
            self.logger.info('return value: %s', str(retvalue))

        if self.entity:
            self.entity.call_method(request.method_name, request.params, callback)
        return response


class RPCManager(TCPConnectionHandlerBase):

    def __init__(self):
        super(RPCManager, self).__init__()
        self.entities = {}

    def handle_new_connection(self, conn):
        super(RPCManager, self).handle_new_connection(conn)
        entity = RPCEntity(MPRPCCodec())
        entity.set_connection(conn)
        entity.service = EchoService()
        entity.service.set_entity(entity)
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
