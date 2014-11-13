__author__ = 'nightfade'

import struct
import msgpack
from rpc.codec import RPCCodec
from rpc.msgpack.base import MPRPCRequest, MPRPCResponse
from rpc.msgpack import message_codec
from utility import logger_manager


class MPRPCCodec(RPCCodec):

    def __init__(self):
        super(MPRPCCodec, self).__init__()
        self.buffer = ''
        self.header_size = struct.calcsize('i')
        self.logger = logger_manager.get_logger(self.__class__.__name__)
        self.message_handler = {
            'RPCRequest': self.handle_request,
            'RPCResponse': self.handle_response
        }

    def create_request(self):
        return MPRPCRequest()

    def create_response(self):
        return MPRPCResponse()

    def handle_data(self, data):
        self.buffer += data
        while True:
            if len(self.buffer) < self.header_size:
                break
            total_size, = struct.unpack('!i', self.buffer[:self.header_size])
            self.logger.debug('total_size: %d', total_size)
            if len(self.buffer) < self.header_size + total_size:
                break
            message = message_codec.decode_message(self.buffer[self.header_size:self.header_size + total_size])
            msgdata = message['msgdata']
            typename = message['typename']
            if typename in self.message_handler:
                self.message_handler[typename](msgdata)
            self.buffer = self.buffer[self.header_size + total_size:]

    def handle_request(self, msgdata):
        msg = msgpack.unpackb(msgdata)
        request = self.create_request()
        request.method_name = msg['methodName']
        request.params = msg['params']
        request.callid = msg['callid']
        if self.delegate:
            self.delegate.handle_request(request)

    def handle_response(self, msgdata):
        msg = msgpack.unpackb(msgdata)
        response = self.create_response()
        response.callid = msg['callid']
        response.retvalue = msg['retvalue']
        if self.delegate:
            self.delegate.handle_response(response)
