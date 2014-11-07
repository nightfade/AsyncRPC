__author__ = 'nightfade'

import socket
import asyncore

from network.tcp_connection import TCPConnection
from utility import logger_manager


class TCPConnectionHandlerBase(object):

    def __init__(self):
        self.logger = logger_manager.get_logger(self.__class__.__name__)

    def handle_new_connection(self, conn):
        self.logger.info('handle_new_connection ' + str(conn.getpeername()))


class TCPServer(asyncore.dispatcher):

    def __init__(self, ip, port, connection_handler):
        asyncore.dispatcher.__init__(self)
        self.logger = logger_manager.get_logger(self.__class__.__name__)
        self.ip = ip
        self.port = port
        self.connection_handler = connection_handler

        self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
        self.set_reuse_addr()
        self.bind((self.ip, self.port))
        self.listen(50)
        self.logger.info('tcp server listening on ' + str((self.ip, self.port)))

    def handle_accept(self):
        try:
            sock, addr = self.accept()
        except socket.error, e:
            self.logger.warning('accept error: ' + e.message)
            return
        except TypeError, e:
            self.logger.warning('accept error: ' + e.message)
            return

        self.logger.info('accept client from ' + str(addr))
        conn = TCPConnection(sock, addr)

        if self.connection_handler:
            self.connection_handler.handle_new_connection(conn)

    def stop(self):
        self.close()
