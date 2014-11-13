//
//  MPRPCRequest.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/13.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "MPRPCRequest.h"
#import "RPCDefine.h"
#import "TransportCodec.h"
#import <NSDictionary+MPMessagePack.h>

@implementation MPRPCRequest

- (NSData *)serialize {
    NSString *typeName = RPCREQUEST_TYPENAME;
    
    NSDictionary *dict = @{
        @"methodName": self.methodName,
        @"params": self.params,
        @"callid": [NSNumber numberWithInt:self.callid]
    };
    
    return [TransportCodec encodeType:typeName withData:[dict mp_messagePack]];
}

@end
