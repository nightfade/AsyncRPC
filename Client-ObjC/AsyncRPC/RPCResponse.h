//
//  RPCResponse.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/11.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCDefine.h"

@interface RPCResponse : NSObject

@property (nonatomic, strong) NSDictionary *returnValue;
@property callid_t callid;

- (NSData *)serialize;

@end
