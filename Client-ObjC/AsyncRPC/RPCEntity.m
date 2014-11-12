//
//  RPCEntity.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "RPCEntity.h"
#import "TCPConnection.h"
#import "ProtobufRPCCodec.h"
#import "RPCCodec.h"

@interface RPCEntity () <TCPConnectionDelegate, RPCCodecDelegate>

@property (strong) TCPConnection *connection;
@property (strong) NSMutableDictionary *callbackTable;
@property callid_t nextCallid;
@property (nonatomic, strong) RPCCodec* codec;

@end


@implementation RPCEntity

- (instancetype)init {
    RPCCodec* codec = [[ProtobufRPCCodec alloc] init];
    return [self initWithCodec:codec];
}

- (instancetype)initWithCodec:(RPCCodec *)codec {
    if (self = [super init]) {
        _codec = codec;
        _codec.delegate = self;
        self.callbackTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)connectHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout {
    self.connection = [[TCPConnection alloc] init];
    self.connection.delegate = self;
    [self.connection connectToHost:host andPort:port withTimeout:timeout];
}

- (void)disconnectAfterFinished:(BOOL)finished {
    [self.connection disconnectAfterFinished:finished];
}

#pragma mark TCPConnectionDelegate

- (void)connectionOpened:(TCPConnection *)conn {
    [self.delegate connectionOpened:self];
}

- (void)connectionClosed:(TCPConnection *)conn {
    [self.delegate connectionClosed:self];
}

- (void)receiveData:(NSData *)data fromConnection:(TCPConnection *)conn {
    NSLog(@"RPCEntity receiveData from TCPConnection");
    [self.codec appendData:data];
}


#pragma mark call RPC method

- (void)callMethod:(NSString *)methodName usingParams:(NSDictionary *)params withCallback:(RPCCallback)callback {
    callid_t callid = self.nextCallid++;
    self.callbackTable[[NSNumber numberWithInt:callid]] = callback;
    
    RPCRequest *request = [self.codec createRequest];
    request.methodName = methodName;
    request.params = params;
    request.callid = callid;
    NSData *data = [request serialize];
    [self.connection writeData:data];
}

- (void)sendCallbackWithID:(callid_t)callid andReturnValue:(NSDictionary *)retvalue {
    RPCResponse *response = [self.codec createResponse];
    response.callid = callid;
    response.returnValue = retvalue;
    NSData *data = [response serialize];
    [self.connection writeData:data];
}

#pragma mark RPCParserDelegate

- (void)handleRPCRequest:(RPCRequest *)request {
    RPCResponse *response = [self.service handleRequest:request];
    [self sendCallbackWithID:response.callid andReturnValue:response.returnValue];
}

- (void)handleRPCResponse:(RPCResponse *)response {
    NSNumber *callidObj =[NSNumber numberWithInteger:response.callid];
    RPCCallback callback = self.callbackTable[callidObj];
    if (callback) {
        callback(response.returnValue);
        [self.callbackTable removeObjectForKey:callidObj];
    } else {
        NSLog(@"Invalid RPC Callback ID: %@", callidObj);
    }
    
}

@end
