//
//  ProtobufTests.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/11.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ProtobufRPCSerializer.h"
#import "ProtobufRPCDeserializer.h"


@interface RPCHandler : NSObject <RPCDeserializerDelegate>

@end

@implementation RPCHandler

- (void)serveMethod:(NSString *)methodName withParams:(NSDictionary *)params {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Method called: %@ with Params %@", methodName, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
}

- (void)callbackWithId:(NSNumber *)callid andReturnValue:(NSDictionary *)retValue {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:retValue options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Callback callid: %@ with retVal %@", callid, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
}

@end


@interface ProtobufTests : XCTestCase

@end

@implementation ProtobufTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testSerialization {
    ProtobufRPCSerializer *serializer = [[ProtobufRPCSerializer alloc] init];
    ProtobufRPCDeserializer *deserializer = [[ProtobufRPCDeserializer alloc] init];
    
    RPCHandler *handler = [[RPCHandler alloc] init];
    
    NSMutableData *buffer = [[NSMutableData alloc] init];
    NSData *data = [serializer serializeMethod:@"testMethod" withParams:@{@"param1": @1, @"param2": @"astring"} andCallid:123];
    [buffer appendData:data];
   
    data = [serializer serializeMethod:@"testMethod2" withParams:@{@"param2": @2} andCallid:234];
    [buffer appendData:data];
    [deserializer handleData:buffer withDelegate:handler];
}

@end
