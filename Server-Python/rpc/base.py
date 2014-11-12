__author__ = 'nightfade'

from utility import logger_manager


class RPCRequest(object):

    def __init__(self, method_name="", params=None, callid=0):
        self.method_name = method_name
        self.params = params
        self.callid = callid

    def serialize(self):
        return None


class RPCResponse(object):

    def __init__(self, callid=0, retvalue=None):
        self.callid = callid
        self.retvalue = retvalue

    def serialize(self):
        return None


class RPCServiceBase(object):

    logger = logger_manager.get_logger('RPCService')

    def handleRequest(self, request):
        RPCServiceBase.logger.debug('handle request: %s %s %d',
                                    request.method_name,
                                    str(request.params),
                                    request.callid)
        return None
