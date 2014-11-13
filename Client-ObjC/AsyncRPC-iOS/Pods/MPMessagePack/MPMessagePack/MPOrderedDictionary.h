//
//  MPOrderedDictionary.h
//  MPMessagePack
//
//  Created by Gabriel on 7/8/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPOrderedDictionary : NSObject <NSFastEnumeration>

@property (readonly) NSUInteger count;

- (instancetype)initWithCapacity:(NSUInteger)capacity;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;

- (void)sortKeysUsingSelector:(SEL)selector deepSort:(BOOL)deepSort;
- (NSArray *)allKeys;

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)reverseKeyEnumerator;

- (NSData *)mp_messagePack;

- (NSDictionary *)toDictionary;

@end
