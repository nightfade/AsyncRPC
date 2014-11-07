__author__ = 'nightfade'

import asyncore
import sys

from network.tcp_server import TCPServer, TCPConnectionHandlerBase
from network.tcp_connection import TCPConnectionDelegate


class EchoServerDelegate(TCPConnectionDelegate):

    def on_disconnected(self):
        super(EchoServerDelegate, self).on_disconnected()

    def on_received(self, data):
        super(EchoServerDelegate, self).on_received(data)
        self.master.write_data(data)


class EchoConnectionHandler(TCPConnectionHandlerBase):

    def handle_new_connection(self, conn):
        super(EchoConnectionHandler, self).handle_new_connection(conn)
        conn.set_delegate(EchoServerDelegate())


class EchoServer(TCPServer):

    def __init__(self, ip, port):
        TCPServer.__init__(self, ip, port, EchoConnectionHandler())


def main(ip, port):
    server = EchoServer(ip, port)
    while True:
        asyncore.loop()


if __name__ == '__main__':
    assert len(sys.argv) >= 3
    listen_ip = sys.argv[1]
    listen_port = int(sys.argv[2])
    main(listen_ip, listen_port)
