//
//  ProtobufRPCCodec.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/11.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCDelegate.h"

#define PROTOBUF_DECODE_EXCEPTION               @"ProtobufDecodeException"
#define PROTOBUF_INVALID_MESSAGE_TYPE_EXCEPTION @"ProtobufInvalidMessageTypeException"
#define PROTOBUF_INVALID_PARAMS_EXCEPTION       @"ProtobufInvalidParamsException"

@interface ProtobufRPCCodec : NSObject <RPCSerializing>

@end
