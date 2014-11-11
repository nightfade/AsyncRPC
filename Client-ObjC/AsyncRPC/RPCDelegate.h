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


@protocol RPCServiceDelegate <NSObject>
- (void)serveMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(callid_t)callid;
- (void)callbackWithId:(NSNumber *)callid andReturnValue:(NSDictionary *)retValue;
@end


@protocol RPCSerializing <NSObject>
- (NSData *)serializeMethod:(NSString *)methodName withParams:(NSDictionary *)params andCallid:(callid_t)callid;
- (NSData *)serializeCallbackID:(callid_t)callid withReturnValue:(NSDictionary *)retvalue;
- (void)handleData:(NSData *)data withService:(id<RPCServiceDelegate>)delegate;
@end

#endif
