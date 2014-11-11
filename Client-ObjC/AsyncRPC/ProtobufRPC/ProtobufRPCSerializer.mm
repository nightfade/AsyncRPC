//
//  ProtobufRPCSerializer.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "ProtobufRPCSerializer.h"
#import <string>
#import "RPCMessage.pb.h"
#import "ProtobufCodec.h"

@implementation ProtobufRPCSerializer

- (instancetype)init {
    if (self = [super init]) {
        GOOGLE_PROTOBUF_VERIFY_VERSION;
    }
    return self;
}

- (NSData *)serializeMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(uint32_t)callid {
    if (![NSJSONSerialization isValidJSONObject:params]) {
        NSLog(@"params is not a valid JSON object!");
        return nil;
    }
    NSError *jsonError;
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    if (paramsData == nil) {
        NSLog(@"NSJsonSerialization Error: %@", jsonError);
        return nil;
    }
    RPCRequest request;
    request.set_methodname([methodName UTF8String]);
    request.set_params([paramsData bytes], [paramsData length]);
    request.set_callid(callid);
    
    std::string serializedData = ProtobufCodec::encode(request);
    return [NSData dataWithBytes:serializedData.data() length:serializedData.size()];
}

@end
