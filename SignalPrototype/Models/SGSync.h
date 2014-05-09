//
//  SGSync.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 24/02/2014.
//  Copyright (c) 2014 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGSync : NSObject

#pragma mark - Singleton

+ (SGSync*)sharedInstance;

#pragma mark - Public methods

+ (void)broadcastSync;

+ (void)broadcastSync:(NSDictionary*)userInfo;

- (void)syncBeforeLastMessageCompleted:(void(^)(NSArray *syncData))completed
                                failed:(void(^)())failed;
- (void)syncBeforeLastMessageAt:(NSDate*)beforeLastMessageAt
                      completed:(void(^)(NSArray *syncData))completed
                         failed:(void(^)())failed;

+ (void)processSyncData:(NSArray*)syncs onCompletion:(void (^)(void))completionBlock;

+ (id)processSyncObject:(NSDictionary*)syncObject;

@end
