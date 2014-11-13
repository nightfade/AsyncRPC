//
//  TransportCodec.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/13.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <Foundation/Foundation.h>

// struct TransportFormat __attribute__ ((__packed__))
// {
//   int32_t  len;
//   int32_t  nameLen;
//   char     typeName[nameLen];
//   char     packageData[len-nameLen-8];
// }

#define kTypeName    @"TypeName"
#define kPackageData @"PackageData"

@interface TransportCodec : NSObject

// output data with length header
+ (NSData *)encodeType:(NSString *)typeName withData:(NSData *)data;

// input data without length header
+ (NSDictionary *)decodeBytes:(const void *)bytes withLength:(int32_t)length;
+ (NSDictionary *)decodeData:(NSData *)data;

+ (int32_t)int32FromBytes:(const char *)bytes;

@end

