//
//  SGDatabase.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 16/09/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"

#import <Foundation/Foundation.h>

@interface SGDatabase : NSObject

+ (FMDatabaseQueue*)getDBQueue;

+ (void)resetAllTables;
+ (void)resetConversationTables;

#pragma mark - Fetches

+ (id)DBQueue:(FMDatabaseQueue*)dbQueue fetchFirstResultWithStatement:(NSString*)statement, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSArray*)DBQueue:(FMDatabaseQueue*)dbQueue fetchAllResultsWithStatement:(NSString*)statement, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Updates

+ (void)DBQueue:(FMDatabaseQueue*)dbQueue
updateWithStatement:(NSString*)statement
      arguments:(NSArray*)arguments
      completed:(void(^)(NSError *error))completedBlock;

@end
