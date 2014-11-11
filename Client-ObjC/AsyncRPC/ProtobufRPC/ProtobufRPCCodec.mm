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


const size_t kHeaderLength = sizeof(int32_t);



@interface ProtobufRPCCodec () {
    std::deque<char> _buffer;
}

- (void)dispatchAndReleaseMessage:(google::protobuf::Message *)message withHandler:(id<RPCServiceDelegate>)handler;

@end



@implementation ProtobufRPCCodec

- (instancetype)init {
    if (self = [super init]) {
        GOOGLE_PROTOBUF_VERIFY_VERSION;
    }
    return self;
}

- (NSData *)serializeMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(callid_t)callid {
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


- (NSData *)serializeCallbackID:(callid_t)callid withReturnValue:(NSDictionary *)retvalue {
    if (![NSJSONSerialization isValidJSONObject:retvalue]) {
        NSLog(@"retvalue is not a valid JSON object!");
        return nil;
    }
    NSError *jsonError;
    NSData *retvalueData = [NSJSONSerialization dataWithJSONObject:retvalue options:0 error:&jsonError];
    if (retvalueData == nil) {
        NSLog(@"NSJsonSerialization Error: %@", jsonError);
        return nil;
    }
    RPCResponse response;
    response.set_callid(callid);
    response.set_retvalue([retvalueData bytes], [retvalueData length]);
    
    std::string serializedData = ProtobufCodec::encode(response);
    return [NSData dataWithBytes:serializedData.data() length:serializedData.size()];
}


- (void)handleData:(NSData *)data withService:(id<RPCServiceDelegate>)delegate {
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
        [self dispatchAndReleaseMessage:message withHandler:delegate];
        
        // 2.4 eat processed data
        _buffer.erase(_buffer.begin(), _buffer.begin() + dataLength);
    }
}


- (void)dispatchAndReleaseMessage:(google::protobuf::Message *)message withHandler:(id<RPCServiceDelegate>)handler {
    if (message->GetTypeName() == "RPCRequest")
    {
        RPCRequest *request = static_cast<RPCRequest *>(message);
        
        // method name
        NSString *methodName = [NSString stringWithUTF8String:request->methodname().c_str()];
        // params json object
        NSData *jsonData = [NSData dataWithBytes:request->params().c_str() length:request->params().size()];
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (nil == jsonObject) {
            @throw [NSException exceptionWithName:PROTOBUF_INVALID_PARAMS_EXCEPTION
                                           reason:@"Invalid JSON Params!"
                                         userInfo:@{@"Error": error}];
        }
        // call id
        callid_t callid = request->callid();
        
        [handler serveMethod:methodName withParams:jsonObject andCallid:callid];
    }
    else if (message->GetTypeName() == "RPCResponse")
    {
        RPCResponse *response = static_cast<RPCResponse *>(message);
        
        // call id
        callid_t callid = response->callid();
        // return value
        std::string retvalueData = response->retvalue();
        NSData *jsonData = [NSData dataWithBytes:retvalueData.c_str() length:retvalueData.size()];
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (nil == jsonObject) {
            @throw [NSException exceptionWithName:PROTOBUF_INVALID_PARAMS_EXCEPTION
                                           reason:@"Invalid JSON Params!"
                                         userInfo:@{@"Error": error}];
        }
        
        [handler callbackWithId:[NSNumber numberWithInt:callid] andReturnValue:jsonObject];
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
