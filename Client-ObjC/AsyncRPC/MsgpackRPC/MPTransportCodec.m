//
//  MsgpackCodec.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/13.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "MPTransportCodec.h"

#include <arpa/inet.h>  // htonl, ntohl
#include <stdint.h>

#import "MPRPCRequest.h"
#import "MPRPCResponse.h"
#import <MPMessagePackReader.h>
#import <MPMessagePackWriter.h>

const int kHeaderLen = sizeof(int32_t);

@implementation MPTransportCodec

+ (NSData *)encodeType:(NSString *)typeName withData:(NSData *)data {
    NSMutableData *package = [[NSMutableData alloc] init];
    
    NSData *typeNameData = [typeName dataUsingEncoding:NSUTF8StringEncoding];
    int32_t nameLen = (int32_t)[typeNameData length];
    int32_t nameLen_be32 = htonl(nameLen);
    int32_t totalLen = (int32_t)(kHeaderLen + nameLen + [data length]);
    int32_t totalLen_be32 = htonl(totalLen);
    
    [package appendBytes:&totalLen_be32 length:sizeof(totalLen_be32)];
    [package appendBytes:&nameLen_be32 length:sizeof(nameLen_be32)];
    [package appendData:typeNameData];
    [package appendData:data];
    
    return package;
}

+ (NSDictionary *)decodeBytes:(const void *)bytes withLength:(int32_t)length {
    int32_t nameLen = [self int32FromBytes:bytes];
    NSString *typeName = [[NSString alloc] initWithBytes:bytes + kHeaderLen length:nameLen encoding:NSUTF8StringEncoding];
    NSData *msgpackData = [NSData dataWithBytes:bytes + kHeaderLen + nameLen length:length - kHeaderLen - nameLen];
    return @{kTypeName:typeName, kMsgpackData: msgpackData};
}

+ (NSDictionary *)decodeData:(NSData *)data {
    int32_t length = (int32_t)[data length];
    const char *bytes = [data bytes];
    return [self decodeBytes:bytes withLength:length];
}

+ (int32_t)int32FromBytes:(const char *)bytes {
    int32_t be32 = 0;
    memcpy(&be32, bytes, sizeof(be32));
    return ntohl(be32);
}

@end
