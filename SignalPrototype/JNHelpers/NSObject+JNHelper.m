//
//  NSObject+JNHelper.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 14/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "NSObject+JNHelper.h"

void runOnMainQueue(void (^block)(void))
{
	if ([NSThread isMainThread]) {
		block();
	}
	else {
		dispatch_sync(dispatch_get_main_queue(), block);
	}
}

void runOnAsyncDefaultQueue(void (^block)(void))
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


@implementation NSObject (JNHelper)

- (BOOL)isNotNullNumber
{
    return (self && [self isKindOfClass:[NSNumber class]]);
}

- (BOOL)isNotNullDictionary
{
    return (self && [self isKindOfClass:[NSDictionary class]]);
}

- (BOOL)isNotNullString
{
    return (self && [self isKindOfClass:[NSString class]] && ((NSString*) self).length > 0);
}

- (BOOL)isEmptyString
{
    return ([self isKindOfClass:[NSString class]] && ((NSString*) self).length == 0);
}

#pragma mark performBlock

- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

@end

@implementation NSString (JNHelper)

+ (BOOL)isNotEmptyString:(id)object
{
    return object && [object isKindOfClass:[NSString class]] && ((NSString*) object).length > 0;
}

+ (BOOL)isNullOrEmptyString:(id)object
{
    return ![self.class isNotEmptyString:object];
}

@end

@implementation NSDate (JNHelper)

+ (BOOL)isNotNullDate:(id)object
{
    return object && [object isKindOfClass:[NSDate class]];
}

@end

@implementation NSNumber (JNHelper)

+ (BOOL)isNotNullNumber:(id)object
{
    return object && [object isKindOfClass:[NSNumber class]];
}

+ (BOOL)isNotANumber:(id)object
{
    return ![self.class isNotNullNumber:object];
}

@end

@implementation NSArray (JNHelper)

+ (BOOL)isNotEmptyArray:(id)object
{
    return object && [object isKindOfClass:[NSArray class]] && ((NSArray*) object).count > 0;
}

+ (BOOL)isEmptyArray:(id)object
{
    return ![self.class isNotEmptyArray:object];
}

+ (BOOL)itemWithinArray:(NSArray*)values1 containedInArray:(NSArray*)values2
{
    __block BOOL containsItem = NO;
    [values1 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *filtered =
        [values2 filteredArrayUsingPredicate:
         [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", obj]];
        if ([NSArray isNotEmptyArray:filtered]) {
            containsItem = YES;
            *stop = YES;
        }
    }];
    return containsItem;
}

@end

@implementation NSOrderedSet (JNHelper)

+ (BOOL)isNotEmptyOrderedSet:(id)object
{
    return object && [object isKindOfClass:[NSOrderedSet class]] && ((NSOrderedSet*) object).count > 0;
}

@end

@implementation NSDictionary (JNHelper)

+ (BOOL)isNotNullDictionary:(id)object
{
    return object && [object isKindOfClass:[NSDictionary class]];
}

@end

@implementation NSMutableDictionary (JNHelper)

+ (BOOL)isNotNullMutableDictionary:(id)object
{
    return object && [object isKindOfClass:[NSMutableDictionary class]];
}

@end

