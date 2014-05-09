//
//  SGVideodata.h
//  HollerbackApp
//
//  Created by Kevin Coulton on 8/27/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@protocol SGVideodataReceiver

- (void)receiveVideodataSync;

@end

@interface SGVideodata : NSObject
{
	NSMutableArray *receiverArray;
}

@property (strong, nonatomic) NSOperationQueue* syncQueue;

@property (strong, nonatomic) NSURLSession *dataManager;

@property (strong, nonatomic) NSDate	*serverLastUpdated;
//@property (strong, nonatomic) NSString	*lastWatchedAt;

// Convenience book-keeping data
@property int colorCode;

+ (SGVideodata*)	sharedInstance;

- (void)addReceiver: (id<SGVideodataReceiver>) receiverToAdd;

- (void)removeReceiver:(id<SGVideodataReceiver>)receiverToRemove;

+ (void)broadcastSyncUpdate;


- (NSString*)serverStyleCurrentTime;

- (void)leaveConversation:(NSNumber*)conversationId;

- (void)syncWithCompleteBlock:(void (^)(void))completionBlock;

@end
