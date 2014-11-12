__author__ = 'nightfade'

import struct
import json
from rpc.codec import RPCCodec
from rpc.protobuf.base import PBRPCRequest, PBRPCResponse
from rpc.protobuf import message_codec
from utility import logger_manager


class PBRPCCodec(RPCCodec):

    def __init__(self):
        super(PBRPCCodec, self).__init__()
        self.buffer = ''
        self.header_size = struct.calcsize('i')
        self.logger = logger_manager.get_logger(self.__class__.__name__)
        self.message_handler = {
            'RPCRequest_pb2': self.handle_request,
            'RPCResponse_pb2': self.handle_response
        }

    def create_request(self):
        return PBRPCRequest()

    def create_response(self):
        return PBRPCResponse()

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
            message_name = message.DESCRIPTOR.full_name
            if message_name in self.message_handler:
                self.message_handler[message_name](message)
            self.buffer = self.buffer[self.header_size + total_size:]

    def handle_request(self, request_pb2):
        request = self.create_request()
        request.method_name = request_pb2.methodName
        request.params = json.loads(request_pb2.params)
        request.callid = request_pb2.callid
        if self.delegate:
            self.delegate.handle_request(request)

    def handle_response(self, response_pb2):
        response = self.create_response()
        response.callid = response_pb2.callid
        response.retvalue = json.loads(response_pb2.retvalue)
        if self.delegate:
            self.delegate.handle_response(response)
