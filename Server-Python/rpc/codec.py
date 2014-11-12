__author__ = 'nightfade'


class RPCCodec(object):

    def __init__(self):
        self.delegate = None

    def set_delegate(self, delegate):
        """
        delegate:
            def handle_request(request)
            def handle_response(response)
        """
        self.delegate = delegate

    def create_request(self):
        return None

    def create_response(self):
        return None

    def handle_data(self, data):
        pass