//
//  ProtobufRPCCodec.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/11.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCCodec.h"

#define PROTOBUF_DECODE_EXCEPTION               @"PBDecodeException"
#define PROTOBUF_INVALID_MESSAGE_TYPE_EXCEPTION @"PBInvalidMessageTypeException"
#define PROTOBUF_INVALID_PARAMS_EXCEPTION       @"PBInvalidParamsException"

@interface ProtobufRPCCodec : RPCCodec

@end
