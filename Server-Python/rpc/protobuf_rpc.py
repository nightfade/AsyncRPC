__author__ = 'nightfade'

import json
import struct

from rpc.entity import RPCSerializerBase, RPCDeserializerBase
from proto import RPCMessage_pb2
from proto.RPCMessage_pb2 import RPCRequest_pb2, RPCResponse_pb2
from utility import logger_manager

from google.protobuf import descriptor_pool, descriptor_database, message_factory, descriptor_pb2


class ProtobufCodec(object):
    """
    Package Format:

        int32_t total_length
        int32_t typename_length
        string typename
        bytes protobuf_data

    """
    logger = logger_manager.get_logger('ProtobufCodec')

    message_types = {
        'RPCRequest_pb2': RPCRequest_pb2,
        'RPCResponse_pb2': RPCResponse_pb2
    }

    @staticmethod
    def encode_message(message):
        """
        :param message:  Protobuf Message Object
        :return: binary bytes with length prefix
        """
        pb_data = message.SerializeToString()
        pb_data_size = len(pb_data)
        typename = message.DESCRIPTOR.full_name
        typename_size = len(typename)
        total_size = struct.calcsize('!i') + typename_size + pb_data_size
        return struct.pack('!ii', total_size, typename_size) + typename + pb_data

    @staticmethod
    def decode_message(package):
        """
        :param package: binary bytes without length prefix
        :return: Protobuf Message Object
        """
        header_size = struct.calcsize('!i')
        typename_size, = struct.unpack('!i', package[:header_size])
        ProtobufCodec.logger.debug('typename_size: %d', typename_size)
        typename = package[header_size: header_size + typename_size]
        pb_data = package[header_size + typename_size:]
        message = ProtobufCodec.get_message(typename)
        message.ParseFromString(pb_data)
        return message

    @staticmethod
    def get_message(typename):
        ProtobufCodec.logger.debug('get message typename: %s in %s', repr(typename), repr(ProtobufCodec.message_types))
        cls = ProtobufCodec.message_types.get(typename, None)
        return cls() if cls else None


class PBRPCSerializer(RPCSerializerBase):

    def serialize_request(self, method_name, params, callid):
        request = RPCRequest_pb2()
        request.methodName = method_name
        request.params = json.dumps(params)
        request.callid = callid
        return ProtobufCodec.encode_message(request)

    def serialize_response(self, callid, retvalue):
        response = RPCResponse_pb2()
        response.callid = callid
        response.retvalue = json.dumps(retvalue)
        return ProtobufCodec.encode_message(response)


class PBRPCDeserializer(RPCDeserializerBase):

    def __init__(self):
        super(PBRPCDeserializer, self).__init__()
        self.buffer = ""
        self.header_size = struct.calcsize('!i')
        self.logger = logger_manager.get_logger(self.__class__.__name__)

    def handle_data(self, data, service):
        self.buffer += data
        while True:
            if len(self.buffer) < self.header_size:
                break
            total_size, = struct.unpack('!i', self.buffer[:self.header_size])
            self.logger.debug('total_size: %d', total_size)
            if len(self.buffer) < self.header_size + total_size:
                break
            message = ProtobufCodec.decode_message(self.buffer[self.header_size:self.header_size + total_size])
            if message.DESCRIPTOR.full_name == 'RPCRequest_pb2':
                service.serve_method(message.methodName, json.loads(message.params), message.callid)
            elif message.DESCRIPTOR.full_name == 'RPCResponse_pb2':
                service.callback(message.callid, json.loads(message.retvalue))
            self.buffer = self.buffer[self.header_size + total_size:]
