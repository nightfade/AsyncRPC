__author__ = 'nightfade'

import socket
import asyncore
from utility import logger_manager


class TCPConnectionDelegate(object):

    def __init__(self):
        self.logger = logger_manager.get_logger(self.__class__.__name__)
        self.master = None

    def set_master(self, master):
        self.master = master

    def on_disconnected(self):
        self.logger.debug('[ on_disconnected ] ' + str(self.master.getpeername()))

    def on_received(self, data):
        self.logger.debug('[ on_received ] ' + repr(data))


class TCPConnection(asyncore.dispatcher):

    DEFAULT_RECV_BUFFER = 4096
    ST_INIT = 0
    ST_ESTABLISHED = 1
    ST_DISCONNECTED = 2

    def __init__(self, sock, peername):
        asyncore.dispatcher.__init__(self, sock)
        self.logger = logger_manager.get_logger(self.__class__.__name__)
        self.peername = peername

        self.writebuff = ''
        self.recv_buffer_size = TCPConnection.DEFAULT_RECV_BUFFER

        self.status = TCPConnection.ST_INIT
        if sock:
            self.status = TCPConnection.ST_ESTABLISHED
            self.setsockopt()

        self.delegate = None

    def setsockopt(self):
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)

    def get_delegate(self):
        return self.delegate

    def set_delegate(self, delegate):
        if delegate == self.delegate:
            return
        if self.delegate:
            self.delegate.set_master(None)

        self.delegate = delegate
        if self.delegate:
            self.delegate.set_master(self)

    def is_established(self):
        return self.status == TCPConnection.ST_ESTABLISHED

    def set_recv_buffer(self, size):
        self.recv_buffer_size = size

    def disconnect(self):
        if self.status == TCPConnection.ST_DISCONNECTED:
            return

        if self.delegate:
            self.delegate.on_disconnected()
        self.set_delegate(None)

        if self.socket:
            asyncore.dispatcher.close(self)

        self.status = TCPConnection.ST_DISCONNECTED

    def getpeername(self):
        return self.peername

    def handle_close(self):
        self.logger.debug('[ TCPConnection handle_close ]')
        asyncore.dispatcher.handle_close(self)
        self.disconnect()

    def handle_expt(self):
        self.logger.debug('[ TCPConnection handle_expt ]')
        asyncore.dispatcher.handle_expt(self)
        self.disconnect()

    def handle_error(self):
        self.logger.debug('[ TCPConnection handle_error ]')
        asyncore.dispatcher.handle_error(self)
        self.disconnect()

    def handle_read(self):
        self.logger.debug('[ TCPConnection handle_read ]')
        data = self.recv(self.recv_buffer_size)
        if data and self.delegate:
            self.delegate.on_received(data)

    def handle_write(self):
        self.logger.debug('[ TCPConnection handle_write ]')
        if self.writebuff:
            size = self.send(self.writebuff)
            self.writebuff = self.writebuff[size:]

    def writable(self):
        if self.status == TCPConnection.ST_ESTABLISHED:
            return len(self.writebuff) > 0
        else:
            return True

    def write_data(self, data):
        self.writebuff += data

