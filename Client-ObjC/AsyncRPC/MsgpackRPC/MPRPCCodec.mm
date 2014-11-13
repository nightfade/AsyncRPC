//
//  MPRPCCodec.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/13.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "MPRPCCodec.h"
#import "MPRPCRequest.h"
#import "MPRPCResponse.h"
#import "MPTransportCodec.h"
#import <MPMessagePackReader.h>

#import <deque>
#import <string>
#import <algorithm>


const size_t kHeaderLength = sizeof(int32_t);


@interface MPRPCCodec () {
    std::deque<char> _buffer;
}

- (void)dispatchPackage:(NSData *)pack withTypeName:(NSString *)typeName;

@end



@implementation MPRPCCodec

- (RPCRequest *)createRequest {
    return [[MPRPCRequest alloc] init];
}

- (RPCResponse *)createResponse {
    return [[MPRPCResponse alloc] init];
}

- (void)appendData:(NSData *)data {
    // 1. copy input data input buffer
    const char *bytes = static_cast<const char*>(data.bytes);
    NSUInteger length = [data length];
    std::copy(bytes, bytes + length, std::back_inserter(_buffer));
    
    // 2. handle data in buffer
    std::string buf;
    while (true) {
        // 2.1 handle length prefix
        if (_buffer.size() < kHeaderLength)
            break;
        buf.resize(kHeaderLength);
        std::copy(_buffer.begin(), _buffer.begin() + kHeaderLength, buf.begin());
        int32_t dataLength = [MPTransportCodec int32FromBytes:buf.c_str()];
        if (_buffer.size() < kHeaderLength + dataLength)
            break;
        _buffer.erase(_buffer.begin(), _buffer.begin() + kHeaderLength);
        
        // 2.2 handle data
        buf.resize(dataLength);
        std::copy(_buffer.begin(), _buffer.begin() + dataLength, buf.begin());
        NSDictionary *msgpackData = [MPTransportCodec decodeBytes:buf.c_str() withLength:(int32_t)buf.size()];
        
        // 2.3 dispatch message
        [self dispatchPackage:msgpackData[kMsgpackData] withTypeName:msgpackData[kTypeName]];
        
        // 2.4 eat processed data
        _buffer.erase(_buffer.begin(), _buffer.begin() + dataLength);
    }
}

- (void)dispatchPackage:(NSData *)pack withTypeName:(NSString *)typeName {
    NSDictionary *dict = [MPMessagePackReader readData:pack error:nil];
    if ([typeName isEqualToString:RPCREQUEST_TYPENAME]) {
        RPCRequest *request = [self createRequest];
        request.methodName = dict[@"methodName"];
        request.params = dict[@"params"];
        request.callid = [dict[@"callid"] intValue];
        [self.delegate handleRPCRequest:request];
    } else if ([typeName isEqualToString:RPCRESPONSE_TYPENAME]) {
        RPCResponse *response = [self createResponse];
        response.callid = [dict[@"callid"] intValue];
        response.returnValue = dict[@"retvalue"];
        [self.delegate handleRPCResponse:response];
    } else {
        NSString *reason = [NSString stringWithFormat:@"*** Invalid Message Type %@!", typeName];
        @throw [NSException exceptionWithName:MP_INVALID_MESSAGE_TYPE_EXCEPTION
                                       reason:reason
                                     userInfo:nil];
    }
}

@end
