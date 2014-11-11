//
//  RPCEntity.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "RPCEntity.h"
#import "TCPConnection.h"
#import "ProtobufRPCSerializer.h"
#import "ProtobufRPCDeserializer.h"

@interface RPCEntity () <TCPConnectionDelegate, RPCDeserializerDelegate>

@property (strong) TCPConnection *connection;
@property (strong) NSMutableDictionary *callbacks;
@property uint32_t nextCallid;
@property (nonatomic, strong) id<RPCSerializer> serializer;
@property (nonatomic, strong) id<RPCDeserializer> deserializer;

@end

@implementation RPCEntity

- (instancetype)init {
    id<RPCSerializer> serializer = [[ProtobufRPCSerializer alloc] init];
    id<RPCDeserializer> deserializer = [[ProtobufRPCDeserializer alloc] init];
    return [self initWithSerializer:serializer andDeserializer:deserializer];
}

- (instancetype)initWithSerializer:(id<RPCSerializer>)serializer andDeserializer:(id<RPCDeserializer>)deserializer {
    if (self = [super init]) {
        _serializer = serializer;
        _deserializer = deserializer;
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

- (void)callMethod:(NSString *)methodName usingParams:(NSDictionary *)params withCallback:(RPCCallback)callback {
    uint32_t callid = self.nextCallid++;
    self.callbacks[[NSNumber numberWithUnsignedInt:callid]] = callback;
    NSData *data = [self.serializer serializeMethod:methodName withParams:params andCallid:callid];
    [self.connection writeData:data];
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
    [self.deserializer handleData:data withDelegate:self];
}

#pragma RPCDeserializerDelegate

- (void)serveMethod:(NSString *)methodName withParams:(NSDictionary *)params {
    [self.service serveMethod:methodName withParams:params];
}


- (void)callbackWithId:(NSNumber *)callid andReturnValue:(NSDictionary *)retValue {
    RPCCallback callback = self.callbacks[callid];
    if (callback) {
        callback(retValue);
        [self.callbacks removeObjectForKey:callid];
    } else {
        NSLog(@"Invalid RPC Callback ID: %@!", callid);
    }
}

@end
