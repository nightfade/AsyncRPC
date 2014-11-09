//
//  RPCEntity.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCSerizalization.h"


@protocol RPCService <NSObject>

- (void)serveMethod:(NSString *)methodName withParams:(NSDictionary *)params;

@end


typedef void(^RPCCallback)(NSDictionary *retValue);


@interface RPCEntity : NSObject

- (instancetype)initWithSerializer:(id<RPCSerializer>)serializer andDeserializer:(id<RPCDeserializer>)deserializer;

@property (nonatomic, strong) id<RPCService> service;


- (void)connectHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout;
- (void)disconnectAfterFinished:(BOOL)finished;
- (void)callMethod:(NSString *)methodName usingParams:(NSDictionary *)params withCallback:(RPCCallback)callback;

@end
