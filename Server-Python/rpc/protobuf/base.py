__author__ = 'nightfade'

import json
from proto.RPCMessage_pb2 import RPCRequest_pb2, RPCResponse_pb2
from rpc.protobuf import message_codec
from rpc.base import RPCRequest, RPCResponse


class PBRPCRequest(RPCRequest):

    def serialize(self):
        request_pb2 = RPCRequest_pb2()
        request_pb2.methodName = self.method_name
        request_pb2.params = json.dumps(self.params)
        request_pb2.callid = self.callid
        return message_codec.encode_message(request_pb2)


class PBRPCResponse(RPCResponse):

    def serialize(self):
        response_pb2 = RPCResponse_pb2()
        response_pb2.callid = self.callid
        response_pb2.retvalue = json.dumps(self.retvalue)
        return message_codec.encode_message(response_pb2)
