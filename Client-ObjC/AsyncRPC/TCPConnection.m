//
//  RPCChannel.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/7.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "TCPConnection.h"
#import <GCDAsyncSocket.h>


#define RPC_CHANNEL_READ_TAG 0
#define RPC_CHANNEL_WRITE_TAG 1

@interface TCPConnection () <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *_socket;
}

@property (nonatomic, strong, readonly) GCDAsyncSocket *socket;

- (void)tryRead;

@end



@implementation TCPConnection

- (GCDAsyncSocket *)socket {
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

- (BOOL)connectToHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout {
    NSLog(@"TCPConnection connectToHost:%@ andPort:%d", host, port);
    NSError *err;
    if (![self.socket connectToHost:host onPort:port withTimeout:timeout error:&err]) {
        NSLog(@"Socket Connect Error: %@", err);
        return NO;
    }
    return YES;
}


- (void)disconnectAfterFinished:(BOOL)finished {
    if (finished) {
        [self.socket disconnectAfterReadingAndWriting];
    } else {
        [self.socket disconnect];
    }
}


- (void)tryRead {
    [self.socket readDataWithTimeout:-1 tag:RPC_CHANNEL_READ_TAG];
}

- (void)writeData:(NSData *)data {
    [self.socket writeData:data withTimeout:-1 tag:RPC_CHANNEL_WRITE_TAG];
}


#pragma mark GCDAsyncSocketDelegate

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self tryRead];
    [self.delegate connectionOpened:self];
}


/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self.delegate connectionClosed:self];
}

/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 *
 * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
 * and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.
 **/
- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    
}


/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self.delegate receiveData:data fromConnection:self];
    [self tryRead];
}


#pragma mark GCDAsyncSocketDelegate Utility

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    
}


@end
