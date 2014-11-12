//
//  RPCService.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/12.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCRequest.h"
#import "RPCResponse.h"

@protocol RPCServiceDelegate <NSObject>

- (RPCResponse *)handleRequest:(RPCRequest *)request;

@end
