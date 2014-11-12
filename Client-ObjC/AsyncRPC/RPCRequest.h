//
//  RPCRequest.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/11.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPCDefine.h"

@interface RPCRequest : NSObject

@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSDictionary *params;
@property callid_t callid;

- (NSData *)serialize;

@end
