//
//  NSObject+JNHelper.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 14/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JNURLBlock)(NSURL *url);
typedef void(^JNKeyBlock)(NSString *key);
typedef void(^JNStringBlock)(NSString *string);
typedef void(^JNErrorBlock)(NSError *error);

void runOnMainQueue(void (^block)(void));
void runOnAsyncDefaultQueue(void (^block)(void));

/**
@see Localizable.strings
 **/
#define JNLocalizedString(var)  NSLocalizedString(var, nil)

/**
 @see Localizable.strings
 **/
#define JNAssert(var) NSAssert(var, ([NSString stringWithFormat:@"Assert failed for %s", #var]))

@interface NSObject (JNHelper)

- (BOOL)isNotNullNumber;
- (BOOL)isNotNullDictionary;
- (BOOL)isNotNullString;
- (BOOL)isEmptyString;

#pragma mark performBlock
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end

@interface NSString (JNHelper)

+ (BOOL)isNotEmptyString:(id)object;
+ (BOOL)isNullOrEmptyString:(id)object;

@end

@interface NSDate (JNHelper)

+ (BOOL)isNotNullDate:(id)object;

+ (NSDateFormatter *)dateFormatter;

+ (NSDateFormatter*)dayTimeDateFormatter;

+ (NSInteger)daysBetweenFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

+ (NSDate*)addDays:(NSInteger)daysToAdd toDate:(NSDate*)date;

+ (NSInteger)secondsBetweenFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

@end

@interface NSNumber (JNHelper)

+ (BOOL)isNotNullNumber:(id)object;
+ (BOOL)isNotANumber:(id)object;

@end

@interface NSArray (JNHelper)

+ (BOOL)isNotEmptyArray:(id)object;

+ (BOOL)isEmptyArray:(id)object;

+ (BOOL)itemWithinArray:(NSArray*)values1 containedInArray:(NSArray*)values2;

@end

@interface NSOrderedSet (JNHelper)

+ (BOOL)isNotEmptyOrderedSet:(id)object;

@end

@interface NSDictionary (JNHelper)

+ (BOOL)isNotNullDictionary:(id)object;

@end

@interface NSMutableDictionary (JNHelper)

+ (BOOL)isNotNullMutableDictionary:(id)object;

@end

