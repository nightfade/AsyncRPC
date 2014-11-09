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

@protocol RPCDeserializerDelegate <NSObject>

- (void)serveMethod:(NSString *)methodName withParams:(NSDictionary *)params;
- (void)callbackWithId:(NSNumber *)callid andReturnValue:(NSDictionary *)retValue;

@end


@protocol RPCSerializer <NSObject>

- (NSData *)serializeMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(uint32_t)callid;

@end


@protocol RPCDeserializer <NSObject>

- (void)handleData:(NSData *)data withDelegate:(id<RPCDeserializerDelegate>)delegate;

@end

#endif
