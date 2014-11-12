//
//  PBRPCRequest.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/12.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "PBRPCRequest.h"
#import "ProtobufCodec.h"
#import "RPCMessage.pb.h"

@implementation PBRPCRequest

- (NSData *)serialize {
    if (![NSJSONSerialization isValidJSONObject:self.params]) {
        NSLog(@"params is not a valid JSON object!");
        return nil;
    }
    NSError *jsonError;
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:self.params options:0 error:&jsonError];
    if (paramsData == nil) {
        NSLog(@"NSJSONSerialization Error: %@", jsonError);
        return nil;
    }
    RPCRequest_pb2 request;
    request.set_methodname([self.methodName UTF8String]);
    request.set_params([paramsData bytes], [paramsData length]);
    request.set_callid(self.callid);
    
    std::string serializedData = ProtobufCodec::encode(request);
    return [NSData dataWithBytes:serializedData.data() length:serializedData.size()];
}

@end
