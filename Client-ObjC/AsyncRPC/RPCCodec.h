//
//  RPCSerializer.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/12.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCRequest.h"
#import "RPCResponse.h"


@protocol RPCCodecDelegate <NSObject>

- (void)handleRPCRequest:(RPCRequest *)request;
- (void)handleRPCResponse:(RPCResponse *)response;

@end



@interface RPCCodec : NSObject

@property (nonatomic, weak) id<RPCCodecDelegate> delegate;

- (RPCRequest *)createRequest;
- (RPCResponse *)createResponse;
- (void)appendData:(NSData *)data;

@end
