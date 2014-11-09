//
//  ProtobufRPCDeserializer.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "ProtobufRPCDeserializer.h"

@interface ProtobufRPCDeserializer ()

@property (nonatomic, strong) NSMutableData *buffer;

@end

@implementation ProtobufRPCDeserializer

- (instancetype)init {
    if (self = [super init]) {
        _buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)handleData:(NSData *)data withDelegate:(id<RPCDeserializerDelegate>)delegate {
    
}

@end
