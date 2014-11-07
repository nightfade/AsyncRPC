__author__ = 'nightfade'

import unittest
import asyncore

from network.tcp_connection import TCPConnection, TCPConnectionDelegate
from network.tcp_server import TCPServer, TCPConnectionHandlerBase
from network.tcp_client import TCPClient
from utility import logger_manager


class TCPConnectionHandler(TCPConnectionHandlerBase):
    """
    Connection Handler for connection test
    """

    def handle_new_connection(self, conn):
        super(TCPConnectionHandler, self).handle_new_connection(conn)


class EchoClientDelegate(TCPConnectionDelegate):
    """
    Client Delegate for echo test
    """

    def on_received(self, data):
        super(EchoClientDelegate, self).on_received(data)
        self.master.on_received(data)


class EchoClient(TCPClient):
    """
    Client for echo test
    """

    def __init__(self, ip, port):
        TCPClient.__init__(self, ip, port)
        self.set_delegate(EchoClientDelegate())
        self.echo_message = ''
        self.mismatch_message = ''

    def test_echo(self, data):
        self.write_data(data)
        self.echo_message += data

    def on_received(self, data):
        if not self.echo_message:
            self.mismatch_message += data
            return
        if not self.echo_message.startswith(data):
            self.mismatch_message += data
            return
        self.echo_message = self.echo_message[len(data):]


class EchoServerDelegate(TCPConnectionDelegate):
    """
    Server Delegate for echo test
    """

    def on_received(self, data):
        if self.master:
            self.master.write_data(data)


class EchoServerConnectionHandler(TCPConnectionHandlerBase):
    """
    Server Connection Handler for echo test
    """

    def handle_new_connection(self, conn):
        super(EchoServerConnectionHandler, self).handle_new_connection(conn)
        server_delegate = EchoServerDelegate()
        conn.set_delegate(server_delegate)


class TCPServerClientTest(unittest.TestCase):

    def setUp(self):
        self.ip = '127.0.0.1'
        self.port = 65432
        self.connection_handler = TCPConnectionHandler()

        self.echo_ip = '127.0.0.1'
        self.echo_port = 54321
        self.echo_handler = EchoServerConnectionHandler()

    def test_async_connect(self):
        logger_manager.get_logger('test_async_connect').info('test case begin')
        server = TCPServer(self.ip, self.port, self.connection_handler)
        client = TCPClient(self.ip, self.port)
        client.async_connect()
        asyncore.loop(timeout=0.1, count=10)

        self.assertEqual(client.status, TCPConnection.ST_ESTABLISHED)

        server.close()
        client.close()
        logger_manager.get_logger('test_async_connect').info('test case end')

    def test_echo(self):
        logger_manager.get_logger('test_echo').info('test case begin')
        server = TCPServer(self.echo_ip, self.echo_port, self.echo_handler)
        client = EchoClient(self.echo_ip, self.echo_port)

        client.async_connect()
        asyncore.loop(timeout=0.1, count=10)

        self.assertEqual(client.status, TCPConnection.ST_ESTABLISHED)

        client.test_echo('hello')
        client.test_echo('world')
        client.test_echo('test')

        asyncore.loop(timeout=0.1, count=10)

        self.assertFalse(client.mismatch_message)
        logger_manager.get_logger('test_echo').info('test case end')
