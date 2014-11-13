//
//  MPRPCResponse.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/13.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "MPRPCResponse.h"
#import "RPCDefine.h"
#import "TransportCodec.h"
#import <NSDictionary+MPMessagePack.h>

@implementation MPRPCResponse

- (NSData *)serialize {
    NSString *typeName = RPCRESPONSE_TYPENAME;
    
    NSDictionary *dict = @{
        @"callid": [NSNumber numberWithInt:self.callid],
        @"retvalue": self.returnValue
    };
    
    return [TransportCodec encodeType:typeName withData:[dict mp_messagePack]];
}

@end
