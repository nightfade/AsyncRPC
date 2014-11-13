__author__ = 'nightfade'

import struct
from utility import logger_manager

"""
Package Format:

    int32_t total_length
    int32_t typename_length
    string typename
    bytes protobuf_data

"""

logger = logger_manager.get_logger('MPMessageCodec')


def encode_message(msgdata, typename):
    """
    :param msgdata: msgpack package
    :return: binary bytes with length prefix
    """
    data_size = len(msgdata)
    typename_size = len(typename)
    total_size = struct.calcsize('!i') + typename_size + data_size
    return struct.pack('!ii', total_size, typename_size) + typename + msgdata


def decode_message(package):
    """
    :param package: binary bytes without length prefix
    :return: (msgdata, typename)
    """
    header_size = struct.calcsize('!i')
    typename_size, = struct.unpack('!i', package[:header_size])
    logger.debug('typename_size: %d', typename_size)
    typename = package[header_size: header_size + typename_size]
    return {
        'msgdata': package[header_size + typename_size:],
        'typename': typename
    }

