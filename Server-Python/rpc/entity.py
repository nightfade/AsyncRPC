__author__ = 'nightfade'

from utility import logger_manager
from network.tcp_connection import TCPConnectionDelegate


class RPCSerializerBase(object):

    def serialize_request(self, method_name, params, callid):
        return None

    def serialize_response(self, callid, retvalue):
        return None


class RPCDeserializerBase(object):

    def handle_data(self, data, service):
        pass


class RPCService(object):

    def serve_method(self, method_name, params, callid):
        logger = logger_manager.get_logger(self.__class__.__name__)
        logger.debug('serve_method %s %s %d' % (method_name, str(params), callid))

    def callback(self, callid, retvalue):
        logger = logger_manager.get_logger(self.__class__.__name__)
        logger.debug('callback %d %s' % (callid, str(retvalue)))


class RPCEntity(TCPConnectionDelegate):

    def __init__(self, serializer, deserializer):
        super(RPCEntity, self).__init__()
        self.serializer = serializer
        self.deserializer = deserializer
        self.service = None
        self.next_callid = 0
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
        self.deserializer.handle_data(data, self.service)

    def call_method(self, method_name, params):
        data = self.serializer.serialize_request(method_name, params, self.next_callid)
        self.next_callid += 1
        self.conn.write_data(data)

    def send_callback(self, callid, params):
        data = self.serializer.serialize_response(callid, params)
        self.conn.write_data(data)

    """ TCPConnectionDelegate """
    def on_disconnected(self):
        super(RPCEntity, self).on_disconnected()

    def on_received(self, data):
        super(RPCEntity, self).on_received(data)
        self.handle_data(data)

