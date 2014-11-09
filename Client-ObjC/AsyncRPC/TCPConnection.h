//
//  RPCChannel.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/7.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCPConnection;


@protocol TCPConnectionDelegate <NSObject>

- (void)receiveData:(NSData *)data fromConnection:(TCPConnection *)conn;
- (void)connectionOpened:(TCPConnection *)conn;
- (void)connectionClosed:(TCPConnection *)conn;

@end



@interface TCPConnection : NSObject

@property (nonatomic, weak) id<TCPConnectionDelegate> delegate;

- (BOOL)connectToHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout;

- (void)disconnectAfterFinished:(BOOL)finished;

- (void)writeData:(NSData *)data;

@end
