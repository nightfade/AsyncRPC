//
//  RPCEntity.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/9.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCCodec.h"
#import "RPCServiceDelegate.h"

@class RPCEntity;

@protocol RPCEntityDelegate <NSObject>

- (void)connectionOpened:(RPCEntity *)entity;
- (void)connectionClosed:(RPCEntity *)entity;

@end


typedef void(^RPCCallback)(NSDictionary *retValue);


@interface RPCEntity : NSObject

- (instancetype)initWithCodec:(RPCCodec *)codec;

@property (weak, nonatomic) id<RPCServiceDelegate> service;
@property (weak, nonatomic) id<RPCEntityDelegate> delegate;

- (void)connectHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout;
- (void)disconnectAfterFinished:(BOOL)finished;
- (void)callMethod:(NSString *)methodName usingParams:(NSDictionary *)params withCallback:(RPCCallback)callback;

@end
