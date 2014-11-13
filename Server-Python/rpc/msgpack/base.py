__author__ = 'nightfade'

import msgpack
from rpc.msgpack import message_codec
from rpc.base import RPCRequest, RPCResponse


class MPRPCRequest(RPCRequest):

    def serialize(self):
        msg = {
            'methodName': self.method_name,
            'params': self.params,
            'callid': self.callid
        }
        msgdata = msgpack.packb(msg)
        return message_codec.encode_message(msgdata, self.typename())


class MPRPCResponse(RPCResponse):

    def serialize(self):
        msg = {
            'callid': self.callid,
            'retvalue': self.retvalue
        }
        msgdata = msgpack.packb(msg)
        return message_codec.encode_message(msgdata, self.typename())
