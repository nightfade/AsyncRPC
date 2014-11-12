__author__ = 'nightfade'

import struct
from proto.RPCMessage_pb2 import RPCRequest_pb2, RPCResponse_pb2
from utility import logger_manager

"""
Package Format:

    int32_t total_length
    int32_t typename_length
    string typename
    bytes protobuf_data

"""

logger = logger_manager.get_logger('ProtobufMessageCodec')

message_types = {
    'RPCRequest_pb2': RPCRequest_pb2,
    'RPCResponse_pb2': RPCResponse_pb2
}


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


def decode_message(package):
    """
    :param package: binary bytes without length prefix
    :return: Protobuf Message Object
    """
    header_size = struct.calcsize('!i')
    typename_size, = struct.unpack('!i', package[:header_size])
    logger.debug('typename_size: %d', typename_size)
    typename = package[header_size: header_size + typename_size]
    pb_data = package[header_size + typename_size:]
    message = get_message(typename)
    message.ParseFromString(pb_data)
    return message


def get_message(typename):
    logger.debug('get message typename: %s in %s', repr(typename), repr(message_types))
    cls = message_types.get(typename, None)
    return cls() if cls else None
