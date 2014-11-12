//
//  ProtobufRPCCodec.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/11.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "ProtobufRPCCodec.h"

#import <string>
#import <deque>
#import <algorithm>
#import <iterator>

#import "RPCMessage.pb.h"
#import "ProtobufCodec.h"
#import "PBRPCRequest.h"
#import "PBRPCResponse.h"


const size_t kHeaderLength = sizeof(int32_t);



@interface ProtobufRPCCodec () {
    std::deque<char> _buffer;
}

- (void)dispatchAndReleaseMessage:(google::protobuf::Message *)message;

@end



@implementation ProtobufRPCCodec

- (instancetype)init {
    if (self = [super init]) {
        GOOGLE_PROTOBUF_VERIFY_VERSION;
    }
    return self;
}

- (RPCRequest *)createRequest {
    return [[PBRPCRequest alloc] init];
}

- (RPCResponse *)createResponse {
    return [[PBRPCResponse alloc] init];
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
        int32_t dataLength = ProtobufCodec::asInt32(buf.c_str());
        if (_buffer.size() < kHeaderLength + dataLength)
            break;
        _buffer.erase(_buffer.begin(), _buffer.begin() + kHeaderLength);
        
        // 2.2 handle data
        buf.resize(dataLength);
        std::copy(_buffer.begin(), _buffer.begin() + dataLength, buf.begin());
        google::protobuf::Message *message = ProtobufCodec::decode(buf);
        if (NULL == message) {
            @throw [NSException exceptionWithName:PROTOBUF_DECODE_EXCEPTION
                                           reason:@"*** Failed to decode protobuf message"
                                         userInfo:@{@"data": [NSData dataWithBytes:buf.c_str() length:buf.size()]}];
        }
        
        // 2.3 dispatch message
        [self dispatchAndReleaseMessage:message];
        
        // 2.4 eat processed data
        _buffer.erase(_buffer.begin(), _buffer.begin() + dataLength);
    }
}

- (void)dispatchAndReleaseMessage:(google::protobuf::Message *)message {
    if (message->GetTypeName() == "RPCRequest_pb2")
    {
        RPCRequest_pb2 *request_pb = static_cast<RPCRequest_pb2 *>(message);
        RPCRequest *request = [self createRequest];
        
        // method name
        request.methodName = [NSString stringWithUTF8String:request_pb->methodname().c_str()];
        
        // params json object
        NSData *jsonData = [NSData dataWithBytes:request_pb->params().c_str() length:request_pb->params().size()];
        NSError *error;
        request.params = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (nil == request.params) {
            @throw [NSException exceptionWithName:PROTOBUF_INVALID_PARAMS_EXCEPTION
                                           reason:@"Invalid JSON Params!"
                                         userInfo:@{@"Error": error}];
        }
        
        // call id
        request.callid = request_pb->callid();
        
        [self.delegate handleRPCRequest:request];
    }
    else if (message->GetTypeName() == "RPCResponse_pb2")
    {
        RPCResponse_pb2 *response_pb2 = static_cast<RPCResponse_pb2 *>(message);
        RPCResponse *response = [self createResponse];
        
        // call id
        response.callid = response_pb2->callid();
        
        // return value
        std::string retvalueData = response_pb2->retvalue();
        NSData *jsonData = [NSData dataWithBytes:retvalueData.c_str() length:retvalueData.size()];
        NSError *error;
        response.returnValue = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (nil == response.returnValue) {
            @throw [NSException exceptionWithName:PROTOBUF_INVALID_PARAMS_EXCEPTION
                                           reason:@"Invalid JSON Params!"
                                         userInfo:@{@"Error": error}];
        }
        
        [self.delegate handleRPCResponse:response];
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"*** Invalid Message Type %s!", message->GetTypeName().c_str()];
        delete message;
        @throw [NSException exceptionWithName:PROTOBUF_INVALID_MESSAGE_TYPE_EXCEPTION
                                       reason:reason
                                     userInfo:nil];
    }
    
    delete message;
}

@end
