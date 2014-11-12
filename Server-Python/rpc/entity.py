__author__ = 'nightfade'

from utility import logger_manager
from network.tcp_connection import TCPConnectionDelegate


class RPCEntity(TCPConnectionDelegate):

    def __init__(self, rpc_codec):
        super(RPCEntity, self).__init__()
        rpc_codec.set_delegate(self)
        self.rpc_codec = rpc_codec
        self.callback_table = {}
        self.next_callid = 0
        self.service = None
        self.conn = None

    def set_connection(self, conn):
        self.conn = conn
        self.conn.set_delegate(self)

    def set_service(self, service):
        if self.service:
            self.service.delegate = None
        self.service = service
        self.service.delegate = self

    def handle_data(self, data):
        self.rpc_codec.handle_data(data)

    def call_method(self, method_name, params, callback):
        request = self.rpc_codec.create_request()
        request.method_name = method_name
        request.params = params
        request.callid = self.next_callid
        self.callback_table[request.callid] = callback
        self.next_callid += 1
        self.conn.write_data(request.serialize())

    def send_callback(self, callid, retvalue):
        response = self.rpc_codec.create_response()
        response.callid = callid
        response.retvalue = retvalue
        self.conn.write_data(response.serialize())

    """ RPCCodecDelegate """
    def handle_request(self, request):
        if self.service:
            response = self.service.handleRequest(request)
            self.send_callback(response.callid, response.retvalue)

    def handle_response(self, response):
        if response.callid in self.callback_table:
            self.callback_table[response.callid](response.retvalue)
            del self.callback_table[response.callid]

    """ TCPConnectionDelegate """
    def on_disconnected(self):
        super(RPCEntity, self).on_disconnected()

    def on_received(self, data):
        super(RPCEntity, self).on_received(data)
        self.handle_data(data)

