__author__ = 'nightfade'

import socket
from network.tcp_connection import TCPConnection
from utility import logger_manager


class TCPClient(TCPConnection):

    def __init__(self, ip, port):
        TCPConnection.__init__(self, None, None)
        self.logger = logger_manager.get_logger(self.__class__.__name__)
        self.ip = ip
        self.port = port

    def close(self):
        self.disconnect()

    def sync_connect(self):
        self.logger.info('try sync_connect ' + str((self.ip, self.port)))
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            sock.connect((self.ip, self.port))
        except socket.error, msg:
            sock.close()
            self.logger.warning('sync_connect failed ' + msg)
            return False

        sock.setblocking(0)
        self.set_socket(sock)
        self.setsockopt()

        self.status = TCPConnection.ST_ESTABLISHED
        return True

    def async_connect(self):
        self.logger.info('try async_connect ' + str((self.ip, self.port)))
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
        self.setsockopt()
        self.connect((self.ip, self.port))

    def handle_connect(self):
        self.logger.info('connection established.')
        self.status = TCPConnection.ST_ESTABLISHED

    def handle_close(self):
        TCPConnection.handle_close(self)