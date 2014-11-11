//
//  ProtobufRPCDeserializer.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCSerizalization.h"

#define PROTOBUF_DECODE_EXCEPTION @"ProtobufDecodeException"
#define INVALID_PROTOBUF_MESSAGE_TYPE_EXCEPTION @"InvalidProtobufMessageTypeException"
#define INVALID_PROTOBUF_PARAMS_EXCEPTION @"InvalidProtobufParamsException"

@interface ProtobufRPCDeserializer : NSObject <RPCDeserializer>

@end
