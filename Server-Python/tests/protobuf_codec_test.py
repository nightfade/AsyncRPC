__author__ = 'meng'

import unittest
import json
import struct

from proto.RPCMessage_pb2 import RPCRequest, RPCResponse
from rpc.protobuf_rpc import ProtobufCodec


class ProtobufTestCase(unittest.TestCase):

    def test_codec(self):
        message = RPCRequest()
        message.methodName = "hello"
        message.params = json.dumps({"param1": 123, "params2": 345})
        message.callid = 1

        pb_data = ProtobufCodec.encode_message(message)

        header_size = struct.calcsize('!i')
        total_size, = struct.unpack('!i', pb_data[:header_size])
        self.assertEqual(header_size + total_size, len(pb_data))

        message2 = ProtobufCodec.decode_message(pb_data[header_size:])
        self.assertEqual(message2.DESCRIPTOR.full_name, 'RPCRequest')
        self.assertEqual(message2.methodName, message.methodName)
        self.assertEqual(message2.params, message.params)
        self.assertEqual(message2.callid, message.callid)

if __name__ == '__main__':
    unittest.main()
