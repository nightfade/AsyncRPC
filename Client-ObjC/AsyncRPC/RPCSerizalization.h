//
//  RPCSerizalization.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#ifndef AsyncRPC_iOS_RPCSerizalization_h
#define AsyncRPC_iOS_RPCSerizalization_h

#import <Foundation/Foundation.h>

typedef int32_t callid_t;


@protocol RPCDeserializerDelegate <NSObject>

- (void)serveMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(callid_t)callid;
- (void)callbackWithId:(NSNumber *)callid andReturnValue:(NSDictionary *)retValue;

@end


@protocol RPCSerializer <NSObject>

- (NSData *)serializeMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(callid_t)callid;

@end


@protocol RPCDeserializer <NSObject>

- (void)handleData:(NSData *)data withDelegate:(id<RPCDeserializerDelegate>)delegate;

@end

#endif
