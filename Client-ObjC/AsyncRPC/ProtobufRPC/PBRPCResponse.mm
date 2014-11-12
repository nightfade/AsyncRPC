//
//  PBRPCResponse.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/12.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "PBRPCResponse.h"
#import "ProtobufCodec.h"
#import "RPCMessage.pb.h"

@implementation PBRPCResponse

- (NSData *)serialize {
    if (![NSJSONSerialization isValidJSONObject:self.returnValue]) {
        NSLog(@"retvalue is not a valid JSON object!");
        return nil;
    }
    NSError *jsonError;
    NSData *retvalueData = [NSJSONSerialization dataWithJSONObject:self.returnValue options:0 error:&jsonError];
    if (retvalueData == nil) {
        NSLog(@"NSJsonSerialization Error: %@", jsonError);
        return nil;
    }
    RPCResponse_pb2 response;
    response.set_callid(self.callid);
    response.set_retvalue([retvalueData bytes], [retvalueData length]);
    
    std::string serializedData = ProtobufCodec::encode(response);
    return [NSData dataWithBytes:serializedData.data() length:serializedData.size()];
}

@end
